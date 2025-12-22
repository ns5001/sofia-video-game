package workinman.display.spine.attachments;

interface AttachmentLoader {
	
	/** @return May be null to not load an attachment. */
	function newRegionAttachment (skin:Skin, name:String, path:String) : RegionAttachment;

	/** @return May be null to not load an attachment. */
	function newMeshAttachment (skin:Skin, name:String, path:String) : MeshAttachment;

	/** @return May be null to not load an attachment. */
	function newWeightedMeshAttachment (skin:Skin, name:String, path:String) : WeightedMeshAttachment;

	/** @return May be null to not load an attachment. */
	function newBoundingBoxAttachment (skin:Skin, name:String) : BoundingBoxAttachment;

	function dispose () : Void;
}
