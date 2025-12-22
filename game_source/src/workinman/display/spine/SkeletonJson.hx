package workinman.display.spine;

import workinman.display.spine.attachments.AttachmentLoader;
import workinman.display.spine.attachments.Attachment;
import workinman.display.spine.attachments.AttachmentType;
import workinman.display.spine.attachments.RegionAttachment;
import workinman.display.spine.attachments.MeshAttachment;
import workinman.display.spine.attachments.WeightedMeshAttachment;
import workinman.display.spine.attachments.BoundingBoxAttachment;
import workinman.display.spine.animation.CurveTimeline;
import workinman.display.spine.animation.Timeline;
import workinman.display.spine.animation.ColorTimeline;
import workinman.display.spine.animation.RotateTimeline;
import workinman.display.spine.animation.AttachmentTimeline;
import workinman.display.spine.animation.TranslateTimeline;
import workinman.display.spine.animation.ScaleTimeline;
import workinman.display.spine.animation.ShearTimeline;
import workinman.display.spine.animation.IkConstraintTimeline;
import workinman.display.spine.animation.FfdTimeline;
import workinman.display.spine.animation.DrawOrderTimeline;
import workinman.display.spine.animation.EventTimeline;
import workinman.display.spine.animation.Animation;
import workinman.display.spine.Exception;

class SkeletonJson {

	public var attachmentLoader : AttachmentLoader;
	public var scale : Float = 1;

	public function new(attachmentLoader : AttachmentLoader = null) {
		this.attachmentLoader = attachmentLoader;
	}

	public function dispose() : Void
	{
		attachmentLoader.dispose();
		attachmentLoader = null;
	}

	/** @param object A String or ByteArray. */
	public function readSkeletonData(object : String, name : String = null) : SkeletonData {
		if (object == null) throw new IllegalArgumentException("object cannot be null.");

		var root:JsonNode = JsonNode.parse(object);

		var skeletonData : SkeletonData = new SkeletonData();
		skeletonData.name = name;

		// Skeleton.
		if (root.hasOwnProperty("skeleton")) {
			var skeletonMap:JsonNode = root.getNode("skeleton");
			skeletonData.hash = skeletonMap.getStr("hash");
			skeletonData.version = skeletonMap.getStr("spine");
			skeletonData.width = skeletonMap.getFloat("width", 0);
			skeletonData.height = skeletonMap.getFloat("height", 0);
		}

		// Bones.
		for (boneMap in root.getNodesArray("bones")) {
			var parent:BoneData = null;
			var parentName:String = boneMap.getStr("parent");
			if (parentName != null) {
				parent = skeletonData.findBone(parentName);
				if (parent == null) throw "Parent bone not found: " + parentName;
			}
			var boneData = new BoneData(boneMap.getStr("name"), parent);
			boneData.length = boneMap.getFloat("length", 0) * scale;
			boneData.x = boneMap.getFloat("x", 0) * scale;
			boneData.y = boneMap.getFloat("y", 0) * scale;
			boneData.rotation = boneMap.getFloat("rotation");
			boneData.scaleX = boneMap.getFloat("scaleX", 1);
			boneData.scaleY = boneMap.getFloat("scaleY", 1);
			boneData.shearX = boneMap.getFloat("shearX", 0);
			boneData.shearY = boneMap.getFloat("shearY", 0);
			boneData.inheritScale = boneMap.getBool("inheritScale", true);
			boneData.inheritRotation = boneMap.getBool("inheritRotation", true);
			skeletonData.bones.push(boneData);
		}

		// IK constraints.
		if (root.hasOwnProperty("ik")) {
			for (ikMap in root.getNodesArray("ik")) {
				var ikConstraintData:IkConstraintData = new IkConstraintData(ikMap.getStr("name"));

				for (boneName in ikMap.getStrArray("bones")) {
					var bone:BoneData = skeletonData.findBone(boneName);
					if (bone == null) throw "IK bone not found: " + boneName;
					ikConstraintData.bones.push(bone);
				}

				ikConstraintData.target = skeletonData.findBone(ikMap.getStr("target"));
				if (ikConstraintData.target == null) throw "Target bone not found: " + ikMap.getStr("target");

				ikConstraintData.bendDirection = ikMap.getBool("bendPositive", true) ? 1 : -1;
				ikConstraintData.mix = ikMap.getFloat("mix", 1);

				skeletonData.ikConstraints.push(ikConstraintData);
			}
		}

		// Transform constraints.
		var transformArray:Array<Dynamic> = root.getNodesArray("transform");
		if(transformArray != null) {
			for (transformMap in root.getNodesArray("transform")) {
				var transformConstraintData:TransformConstraintData = new TransformConstraintData(transformMap.getStr("name"));

				var boneName:String = transformMap.getStr("bone");
				transformConstraintData.bone = skeletonData.findBone(boneName);
				if (transformConstraintData.bone == null) throw new Exception("Bone not found: " + boneName);

				var targetName:String = transformMap.getStr("target");
				transformConstraintData.target = skeletonData.findBone(targetName);
				if (transformConstraintData.target == null) throw new Exception("Target bone not found: " + targetName);

				transformConstraintData.offsetRotation = transformMap.getFloat("rotation", 0);
				transformConstraintData.offsetX = transformMap.getFloat("x", 0) * scale;
				transformConstraintData.offsetY = transformMap.getFloat("y", 0) * scale;
				transformConstraintData.offsetScaleX = transformMap.getFloat("scaleX", 0) * scale;
				transformConstraintData.offsetScaleY = transformMap.getFloat("scaleY", 0) * scale;
				transformConstraintData.offsetShearY = transformMap.getFloat("shearY", 0) * scale;

				transformConstraintData.rotateMix = transformMap.getFloat("rotateMix", 1);
				transformConstraintData.translateMix = transformMap.getFloat("translateMix", 1);
				transformConstraintData.scaleMix = transformMap.getFloat("scaleMix", 1);
				transformConstraintData.shearMix = transformMap.getFloat("shearMix", 1);

				skeletonData.transformConstraints.push(transformConstraintData);
			}
		}
		transformArray = null;

		// Slots.
		for (slotMap in root.getNodesArray("slots")) {
			var boneName = slotMap.getStr("bone");
			var boneData = skeletonData.findBone(boneName);
			if (boneData == null) throw "Slot bone not found: " + boneName;
			var slotData:SlotData = new SlotData(slotMap.getStr("name"), boneData);

			var color:String = slotMap.getStr("color");
			if (color != null) {
				slotData.r = toColor(color, 0);
				slotData.g = toColor(color, 1);
				slotData.b = toColor(color, 2);
				slotData.a = toColor(color, 3);
			}

			slotData.attachmentName = slotMap.getStr("attachment");
			slotData.blendMode = slotMap.getStr("blend", "normal");

			skeletonData.slots.push(slotData);
		}

		var tNodesArray = root.getNodesArray("skins");

		// Skins. 
		if(tNodesArray.length > 0) { // Newer Spine Versions, 3.8 and greater
			for (skinNode in tNodesArray) {
				var skinName = skinNode.getStr("name");

				var skinMap:JsonNode = skinNode.getNode("attachments");
				var skin:Skin = new Skin(skinName);
				for (slotName in skinMap.fields()) {
					var slotIndex:Int = skeletonData.findSlotIndex(slotName);
					var slotEntry:JsonNode = skinMap.getNode(slotName);
					for (attachmentName in slotEntry.fields()) {
						var attachment:Attachment = readAttachment(skin, attachmentName, slotEntry.getNode(attachmentName));
						if (attachment != null)
							skin.addAttachment(slotIndex, attachmentName, attachment);
					}
				}

				skeletonData.skins.push(skin);
				if (skin.name == "default")
					skeletonData.defaultSkin = skin;
			}
		} else { // Older Spine Versions, Earlier than 3.8
			var skins:JsonNode = root.getNode("skins");
			for (skinName in skins.fields()) {
				var skinMap:JsonNode = skins.getNode(skinName);
				var skin:Skin = new Skin(skinName);
				for (slotName in skinMap.fields()) {
					var slotIndex:Int = skeletonData.findSlotIndex(slotName);
					var slotEntry:JsonNode = skinMap.getNode(slotName);
					for (attachmentName in slotEntry.fields()) {
						var attachment:Attachment = readAttachment(skin, attachmentName, slotEntry.getNode(attachmentName));
						if (attachment != null)
							skin.addAttachment(slotIndex, attachmentName, attachment);
					}
				}
				skeletonData.skins.push(skin);
				if (skin.name == "default")
					skeletonData.defaultSkin = skin;
			}
		}

		// Events.
		var events:JsonNode = root.getNode("events");
		if (events != null) {
			for (eventName in events.fields()) {
				var eventMap:JsonNode = events.getNode(eventName);
				var eventData:EventData = new EventData(eventName);
				eventData.intValue = eventMap.getInt("int", 0);
				eventData.floatValue = eventMap.getFloat("float", 0);
				eventData.stringValue = eventMap.getStr("string", null);
				skeletonData.events.push(eventData);
			}
		}

		// Animations.
		var animations:JsonNode = root.getNode("animations");
		for (animationName in animations.fields())
			readAnimation(animationName, animations.getNode(animationName), skeletonData);

		return skeletonData;
	}

	private function readAttachment(skin : Skin, name : String, map : JsonNode) : Attachment {
		name = map.getStr("name", name);

		var typeName : String = map.getStr("type", "region");
		if (typeName == "skinnedmesh") typeName = "weightedmesh";
		var type : AttachmentType = new AttachmentType(0, typeName);
		var path : String = map.getStr("path", name);

		var scale : Float = this.scale;
		var color : String;
		var vertices : Array<Float>;
		switch (typeName) {
			case AttachmentType.region:
				var region : RegionAttachment = attachmentLoader.newRegionAttachment(skin, name, path);
				if (region == null) return null;
				region.path = path;
				region.x = map.getFloat("x", 0) * scale;
				region.y = map.getFloat("y", 0) * scale;
				region.scaleX = map.getFloat("scaleX", 1);
				region.scaleY = map.getFloat("scaleY", 1);
				region.rotation = map.getFloat("rotation", 0);
				region.width = map.getFloat("width", 0) * scale;
				region.height = map.getFloat("height", 0) * scale;
				color = map.getStr("color");
				if (color != null && color != "") {
					region.r = toColor(color, 0);
					region.g = toColor(color, 1);
					region.b = toColor(color, 2);
					region.a = toColor(color, 3);
				}
				region.updateOffset();
				return region;
			case AttachmentType.mesh:
				var mesh : MeshAttachment = attachmentLoader.newMeshAttachment(skin, name, path);
				if (mesh == null) return null;
				mesh.path = path;
				mesh.vertices = getFloatArray(map, "vertices", scale);
				mesh.triangles = getUIntArray(map, "triangles");
				mesh.regionUVs = getFloatArray(map, "uvs", 1);
				mesh.updateUVs();
				color = map.getStr("color");
				if (color != null && color != "") {
					mesh.r = toColor(color, 0);
					mesh.g = toColor(color, 1);
					mesh.b = toColor(color, 2);
					mesh.a = toColor(color, 3);
				}
				mesh.hullLength = map.getInt("hull", 0) * 2;
				if (map.hasOwnProperty("edges")) mesh.edges = getIntArray(map, "edges");
				mesh.width = map.getFloat("width", 0) * scale;
				mesh.height = map.getFloat("height", 0) * scale;
				return mesh;
			case AttachmentType.weightedmesh:
				var weightedMesh : WeightedMeshAttachment = attachmentLoader.newWeightedMeshAttachment(skin, name, path);
				if (weightedMesh == null) return null;
				weightedMesh.path = path;
				var uvs : Array<Float> = getFloatArray(map, "uvs", 1);
				vertices = getFloatArray(map, "vertices", 1);
				var weights : Array<Float> = new Array<Float>();
				var bones : Array<Int> = new Array<Int>();
				var i:Int = 0;
				var n:Int = vertices.length;
				while(i < n) {
					var boneCount : Int = Math.floor(vertices[i++]);
					bones[bones.length] = boneCount;
					var nn:Int = i + boneCount * 4;
					while(i < nn) {
						bones[bones.length] = Math.floor(vertices[i]);
						weights[weights.length] = vertices[i + 1] * scale;
						weights[weights.length] = vertices[i + 2] * scale;
						weights[weights.length] = vertices[i + 3];
						i += 4;
					}
				}
				weightedMesh.bones = bones;
				weightedMesh.weights = weights;
				weightedMesh.triangles = getUIntArray(map, "triangles");
				weightedMesh.regionUVs = uvs;
				weightedMesh.updateUVs();
				color = map.getStr("color");
				if (color != null && color != "") {
					weightedMesh.r = toColor(color, 0);
					weightedMesh.g = toColor(color, 1);
					weightedMesh.b = toColor(color, 2);
					weightedMesh.a = toColor(color, 3);
				}
				weightedMesh.hullLength = map.getInt("hull", 0) * 2;
				if (map.hasOwnProperty("edges")) weightedMesh.edges = getIntArray(map, "edges");
				weightedMesh.width = map.getFloat("width", 0) * scale;
				weightedMesh.height = map.getFloat("height", 0) * scale;
				return weightedMesh;
			case AttachmentType.boundingbox:
				var box : BoundingBoxAttachment = attachmentLoader.newBoundingBoxAttachment(skin, name);
				vertices = box.vertices;
				for (poInt in map.getDynamicArray("vertices"))
					vertices[vertices.length] = poInt * scale;
				return box;
		}

		return null;
	}

	private function readAnimation(name : String, map : JsonNode, skeletonData : SkeletonData) : Void {
		var timelines : Array<Timeline> = new Array<Timeline>();
		var duration : Float = 0;

		var slotMap : JsonNode;
		var slotIndex : Int;
		var slotName : String;
		var values : Array<JsonNode>;
		var valueMap : JsonNode;
		var frameIndex : Int;
		var i : Int;
		var timelineName : String;

		var slots : JsonNode = map.getNode("slots");
		for (slotName in slots.fields()) {
			slotMap = slots.getNode(slotName);
			slotIndex = skeletonData.findSlotIndex(slotName);

			for (timelineName in slotMap.fields()) {
				values = slotMap.getDynamicArray(timelineName);
				if (timelineName == "color") {
					var colorTimeline : ColorTimeline = new ColorTimeline(values.length);
					colorTimeline.slotIndex = slotIndex;

					frameIndex = 0;
					for (valueMap in values) {
						var color : String = valueMap.getStr("color");
						var r : Float = toColor(color, 0);
						var g : Float = toColor(color, 1);
						var b : Float = toColor(color, 2);
						var a : Float = toColor(color, 3);
						colorTimeline.setFrame(frameIndex, valueMap.getFloat("time"), r, g, b, a);
						readCurve(colorTimeline, frameIndex, valueMap);
						frameIndex++;
					}
					timelines[timelines.length] = colorTimeline;
					duration = Math.max(duration, colorTimeline.frames[colorTimeline.frameCount * 5 - 5]);
				} else if (timelineName == "attachment") {
					var attachmentTimeline : AttachmentTimeline = new AttachmentTimeline(values.length);
					attachmentTimeline.slotIndex = slotIndex;

					frameIndex = 0;
					for (valueMap in values)
						attachmentTimeline.setFrame(frameIndex++, valueMap.getFloat("time"), valueMap.getStr("name"));
					timelines[timelines.length] = attachmentTimeline;
					duration = Math.max(duration, attachmentTimeline.frames[attachmentTimeline.frameCount - 1]);
				} else
					throw new Exception("Invalid timeline type for a slot: " + timelineName + " (" + slotName + ")");
			}
		}

		var bones : JsonNode = map.getNode("bones");
		for (boneName in bones.fields()) {
			var boneIndex : Int = skeletonData.findBoneIndex(boneName);
			if (boneIndex == -1) throw new Exception("Bone not found: " + boneName);
			var boneMap : JsonNode = bones.getNode(boneName);

			for (timelineName in boneMap.fields()) {
				values = boneMap.getNodesArray(timelineName);
				if (timelineName == "rotate") {
					var rotateTimeline : RotateTimeline = new RotateTimeline(values.length);
					rotateTimeline.boneIndex = boneIndex;

					frameIndex = 0;
					for (valueMap in values) {
						rotateTimeline.setFrame(frameIndex, valueMap.getFloat("time"), valueMap.getFloat("angle"));
						readCurve(rotateTimeline, frameIndex, valueMap);
						frameIndex++;
					}
					timelines[timelines.length] = rotateTimeline;
					duration = Math.max(duration, rotateTimeline.frames[rotateTimeline.frameCount * 2 - 2]);
				} else if (timelineName == "translate" || timelineName == "scale" || timelineName == "shear") {
					var timeline : TranslateTimeline;
					var timelineScale : Float = 1;
					if (timelineName == "scale") {
						timeline = new ScaleTimeline(values.length);
						timeline.boneIndex = boneIndex;

						frameIndex = 0;
						for (valueMap in values) {
							var x : Float = valueMap.getFloat("x", 1) * timelineScale;
							var y : Float = valueMap.getFloat("y", 1) * timelineScale;
							timeline.setFrame(frameIndex, valueMap.getFloat("time"), x, y);
							readCurve(timeline, frameIndex, valueMap);
							frameIndex++;
						}
					} else if(timelineName == "shear") {
						timeline = new ShearTimeline(values.length);
						timeline.boneIndex = boneIndex;

						frameIndex = 0;
						for (valueMap in values) {
							var x : Float = valueMap.getFloat("x", 0) * timelineScale;
							var y : Float = valueMap.getFloat("y", 0) * timelineScale;
							timeline.setFrame(frameIndex, valueMap.getFloat("time"), x, y);
							readCurve(timeline, frameIndex, valueMap);
							frameIndex++;
						}
					} else {
						timeline = new TranslateTimeline(values.length);
						timelineScale = scale;
						timeline.boneIndex = boneIndex;

						frameIndex = 0;
						for (valueMap in values) {
							var x : Float = valueMap.getFloat("x", 0) * timelineScale;
							var y : Float = valueMap.getFloat("y", 0) * timelineScale;
							timeline.setFrame(frameIndex, valueMap.getFloat("time"), x, y);
							readCurve(timeline, frameIndex, valueMap);
							frameIndex++;
						}
					}
					
					timelines[timelines.length] = timeline;
					duration = Math.max(duration, timeline.frames[timeline.frameCount * 3 - 3]);
				} else
					throw new Exception("Invalid timeline type for a bone: " + timelineName + " (" + boneName + ")");
			}
		}

		var ikMap : JsonNode = map.getNode("ik");
		for (ikConstraintName in ikMap.fields()) {
			var ikConstraint : IkConstraintData = skeletonData.findIkConstraint(ikConstraintName);
			values = ikMap.getDynamicArray(ikConstraintName);
			var ikTimeline : IkConstraintTimeline = new IkConstraintTimeline(values.length);
			ikTimeline.ikConstraintIndex = skeletonData.ikConstraints.indexOf(ikConstraint);
			frameIndex = 0;
			for (valueMap in values) {
				var mix : Float = valueMap.getFloat("mix", 1);
				var bendDirection : Int = valueMap.getBool("bendPositive", true) ? 1 : -1;
				ikTimeline.setFrame(frameIndex, valueMap.getFloat("time"), mix, bendDirection);
				readCurve(ikTimeline, frameIndex, valueMap);
				frameIndex++;
			}
			timelines[timelines.length] = ikTimeline;
			duration = Math.max(duration, ikTimeline.frames[ikTimeline.frameCount * 3 - 3]);
		}

		var ffd : JsonNode = map.getNode("ffd");
		for (skinName in ffd.fields()) {
			var skin : Skin = skeletonData.findSkin(skinName);
			slotMap = ffd.getNode(skinName);
			for (slotName in slotMap.fields()) {
				slotIndex = skeletonData.findSlotIndex(slotName);
				var meshMap : JsonNode = slotMap.getNode(slotName);
				for (meshName in meshMap.fields()) {
					values = meshMap.getDynamicArray(meshName);
					var ffdTimeline : FfdTimeline = new FfdTimeline(values.length);
					var attachment : Attachment = skin.getAttachment(slotIndex, meshName);
					if (attachment == null) throw new Exception("FFD attachment not found: " + meshName);
					ffdTimeline.slotIndex = slotIndex;
					ffdTimeline.attachment = attachment;

					var vertexCount : Int;
					if (Std.is(attachment, MeshAttachment))
						vertexCount = cast(attachment, MeshAttachment).vertices.length;
					else
						vertexCount = Math.floor(cast(attachment, WeightedMeshAttachment).weights.length / 3 * 2);

					frameIndex = 0;
					for (valueMap in values) {
						var vertices : Array<Float>;
						if (!valueMap.hasOwnProperty("vertices")) {
							if (Std.is(attachment, MeshAttachment))
								vertices = cast(attachment, MeshAttachment).vertices;
							else
								vertices = new Array<Float>();
						} else {
							var verticesValue:Array<Float> = valueMap.getFloatArray("vertices", 1);
							vertices = ArrayUtils.allocFloat(vertexCount);
							var start : Int = valueMap.getInt("offset", 0);
							var n : Int = verticesValue.length;
							if (scale == 1) {
								for(i in 0...n)
									vertices[i + start] = verticesValue[i];
							} else {
								for(i in 0...n)
									vertices[i + start] = verticesValue[i] * scale;
							}
							if (Std.is(attachment, MeshAttachment)) {
								var meshVertices : Array<Float> = cast(attachment, MeshAttachment).vertices;
								for(i in 0...vertexCount)
									vertices[i] += meshVertices[i];
							}
						}

						ffdTimeline.setFrame(frameIndex, valueMap.getFloat("time"), vertices);
						readCurve(ffdTimeline, frameIndex, valueMap);
						frameIndex++;
					}
					timelines[timelines.length] = ffdTimeline;
					duration = Math.max(duration, ffdTimeline.frames[ffdTimeline.frameCount - 1]);
				}
			}
		}

		var drawOrderValues :Array<JsonNode> = map.getNodesArray("drawOrder");
		if (drawOrderValues == null) drawOrderValues = map.getNodesArray("draworder");
		if (drawOrderValues != null && drawOrderValues.length > 0) {
			var drawOrderTimeline : DrawOrderTimeline = new DrawOrderTimeline(drawOrderValues.length);
			var slotCount : Int = skeletonData.slots.length;
			frameIndex = 0;
			for (drawOrderMap in drawOrderValues) {
				var drawOrder : Array<Int> = null;
				if (drawOrderMap.hasOwnProperty("offsets")) {
					drawOrder = new Array<Int>();
					var i:Int = slotCount - 1;
					while(i >= 0) {
						drawOrder[i] = -1;
						i--;
					}
					var offsets : Array<JsonNode> = drawOrderMap.getNodesArray("offsets");
					var unchanged : Array<Int> = new Array<Int>();
					var originalIndex : Int = 0, unchangedIndex : Int = 0;
					for (offsetMap in offsets) {
						slotIndex = skeletonData.findSlotIndex(offsetMap.getStr("slot"));
						if (slotIndex == -1) throw new Exception("Slot not found: " + offsetMap.getStr("slot"));
						// Collect unchanged items.
						while (originalIndex != slotIndex)
							unchanged[unchangedIndex++] = originalIndex++;
						// Set changed items.
						drawOrder[originalIndex + offsetMap.getInt("offset")] = originalIndex++;
					}
					// Collect remaining unchanged items.
					while (originalIndex < slotCount)
						unchanged[unchangedIndex++] = originalIndex++;
					// Fill in unchanged items.
					var i:Int = slotCount - 1;
					while(i >= 0) {
						if (drawOrder[i] == -1) drawOrder[i] = unchanged[--unchangedIndex];
						i--;
					}
				}
				drawOrderTimeline.setFrame(frameIndex++, drawOrderMap.getFloat("time"), drawOrder);
			}
			timelines[timelines.length] = drawOrderTimeline;
			duration = Math.max(duration, drawOrderTimeline.frames[drawOrderTimeline.frameCount - 1]);
		}

		var eventsMap :Array<JsonNode> = map.getNodesArray("events");
		if (eventsMap != null && eventsMap.length > 0) {
			var eventTimeline : EventTimeline = new EventTimeline(eventsMap.length);
			frameIndex = 0;
			for (eventMap in eventsMap) {
				var eventData : EventData = skeletonData.findEvent(eventMap.getStr("name"));
				if (eventData == null) throw new Exception("Event not found: " + eventMap.getStr("name"));
				var event : Event = new Event(eventMap.getFloat("time"), eventData);
				event.intValue = eventMap.getInt("Int", eventData.intValue);
				event.floatValue = eventMap.getFloat("float", eventData.floatValue);
				event.stringValue = eventMap.getStr("string", eventData.stringValue);
				eventTimeline.setFrame(frameIndex++, event);
			}
			timelines[timelines.length] = eventTimeline;
			duration = Math.max(duration, eventTimeline.frames[Math.floor(eventTimeline.frameCount - 1)]);
		}

		skeletonData.animations[skeletonData.animations.length] = new Animation(name, timelines, duration);
	}

	static private function readCurve(timeline : CurveTimeline, frameIndex : Int, valueMap : JsonNode) : Void {
		var curve : Dynamic = valueMap.getDynamic("curve");
		if (curve == null) return;
		
		if (curve == "stepped") {
			timeline.setStepped(frameIndex);
		} else if (Std.is(curve, Array)) {
			timeline.setCurve(frameIndex, curve[0], curve[1], curve[2], curve[3]);
		} else {
			// bezier curve
			timeline.setCurve(frameIndex, curve, valueMap.getFloat("c2", 0), valueMap.getFloat("c3", 1), valueMap.getFloat("c4", 1));
		}
	}

	static private function toColor(hexString : String, colorIndex : Int) : Float {
		if (hexString.length != 8) throw new IllegalArgumentException("Color hexidecimal length must be 8, recieved: " + hexString);
		return Std.parseInt("0x" + hexString.substring(colorIndex * 2, colorIndex * 2 + 2)) / 255;
	}

	static private function getFloatArray(map : JsonNode, name : String, scale : Float) : Array<Float> {
		var list : Array<Int> = map.getIntArray(name);
		var values : Array<Float> = new Array<Float>();
		var i : Int = 0, n : Int = list.length;
		if (scale == 1) {
			for(i in 0...n)
				values[i] = list[i];
		} else {
			for(i in 0...n)
				values[i] = list[i] * scale;
		}
		return values;
	}

	static private function getIntArray(map : JsonNode, name : String) : Array<Int> {
		var list : Array<Int> = map.getIntArray(name);
		var values : Array<Int> = new Array<Int>();
		for(i in 0...list.length)
			values[i] = list[i];
		return values;
	}

	static private function getUIntArray(map : JsonNode, name : String) : Array<Int> {
		var list : Array<Int> = map.getIntArray(name);
		var values : Array<Int> = new Array<Int>();
		for(i in 0...list.length)
			values[i] = list[i];
		return values;
	}
}
