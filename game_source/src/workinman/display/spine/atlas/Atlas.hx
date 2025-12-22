package workinman.display.spine.atlas;

import workinman.display.spine.Exception;

class Atlas {

	private var pages:Array<AtlasPage> = new Array<AtlasPage>();
	private var regions:Array<AtlasRegion> = new Array<AtlasRegion>();
	private var textureLoader:TextureLoader;

	/** @param object A String  */
	public function new (object:String, textureLoader:TextureLoader) {
		if (object == "")
			return;
		load(object, textureLoader);
	}

	public function dispose() : Void
	{
		for (i in 0 ... pages.length) {
			textureLoader.unloadPage(pages[i]);
		}
		for(p in pages) {
			p.dispose();
		}
		pages = null;
		for(r in regions) {
			r.dispose();
		}
		regions = null;
		textureLoader.dispose();
		textureLoader = null;
	}

	private function load (atlasText:String, textureLoader:TextureLoader) : Void {
		if (textureLoader == null)
			throw new IllegalArgumentException("textureLoader cannot be null.");
		this.textureLoader = textureLoader;

		var reader:Reader = new Reader(atlasText);
		var tuple:Array<String> = ArrayUtils.allocString(4);
		var page:AtlasPage = null;
		while (true) {
			var line:String = reader.readLine();
			if (line == null)
				break;
			line = reader.trim(line);

			if (line.length == 0)
				page = null;
			else if (page == null) {
				page = new AtlasPage();
				page.name = line;

				if (reader.readTuple(tuple) == 2) { // size is only optional for an atlas packed with an old TexturePacker.
					page.width = Std.parseInt(tuple[0]);
					page.height = Std.parseInt(tuple[1]);
					reader.readTuple(tuple);
				}
				page.format = tuple[0];

				reader.readTuple(tuple);
				page.minFilter = tuple[0];
				page.magFilter = tuple[1];

				var direction:String = reader.readValue();
				page.uWrap = TextureWrap.clampToEdge;
				page.vWrap = TextureWrap.clampToEdge;
				if (direction == "x")
					page.uWrap = TextureWrap.repeat;
				else if (direction == "y")
					page.vWrap = TextureWrap.repeat;
				else if (direction == "xy")
					page.uWrap = page.vWrap = TextureWrap.repeat;

				textureLoader.loadPage(page, line);

				pages.push(page);

			} else {
				var region:AtlasRegion = new AtlasRegion();
				region.name = line;
				region.page = page;

				region.rotate = reader.readValue() == "true";

				reader.readTuple(tuple);
				var x:Int = Std.parseInt(tuple[0]);
				var y:Int = Std.parseInt(tuple[1]);

				reader.readTuple(tuple);
				var width:Int = Std.parseInt(tuple[0]);
				var height:Int = Std.parseInt(tuple[1]);

				region.u = x / page.width;
				region.v = y / page.height;
				if (region.rotate) {
					region.u2 = (x + height) / page.width;
					region.v2 = (y + width) / page.height;
				} else {
					region.u2 = (x + width) / page.width;
					region.v2 = (y + height) / page.height;
				}
				region.x = x;
				region.y = y;
				region.width = Math.floor(Math.abs(width));
				region.height = Math.floor(Math.abs(height));

				if (reader.readTuple(tuple) == 4) { // split is optional
					region.splits = [Std.parseInt(tuple[0]), Std.parseInt(tuple[1]), Std.parseInt(tuple[2]), Std.parseInt(tuple[3])];

					if (reader.readTuple(tuple) == 4) { // pad is optional, but only present with splits
						region.pads = [Std.parseInt(tuple[0]), Std.parseInt(tuple[1]), Std.parseInt(tuple[2]), Std.parseInt(tuple[3])];

						reader.readTuple(tuple);
					}
				}

				region.originalWidth = Std.parseInt(tuple[0]);
				region.originalHeight = Std.parseInt(tuple[1]);

				reader.readTuple(tuple);
				region.offsetX = Std.parseInt(tuple[0]);
				region.offsetY = Std.parseInt(tuple[1]);

				region.index = Std.parseInt(reader.readValue());

				textureLoader.loadRegion(region);
				regions.push(region);
			}
		}
	}

	/** Returns the first region found with the specified name. This method uses string comparison to find the region, so the result
	 * should be cached rather than calling this method multiple times.
	 * @return The region, or null. */
	public function findRegion (name:String) : AtlasRegion {
		for(i in 0...regions.length) {
			if (regions[i].name == name) {
				return regions[i];
			}
		}
		return null;
	}
}

class Reader {
	private var lines:Array<String>;
	private var index:Int = 0;

	public function new (text:String) {
		var regex:EReg = new EReg("[ \t]*((\r\n)|\r|\n)[ \t]*", "g");
		lines = regex.split(text);
	}

	public function trim (value:String) : String {
		return StringTools.trim(value);
	}

	public function readLine () : String {
		if (index >= lines.length)
			return null;
		return lines[index++];
	}

	public function readValue () : String {
		var line:String = readLine();
		var colon:Int = line.indexOf(":");
		if (colon == -1)
			throw new Exception("Invalid line: " + line);
		return trim(line.substring(colon + 1));
	}

	/** Returns the number of tuple values read (1, 2 or 4). */
	public function readTuple (tuple:Array<String>) : Int {
		var line:String = readLine();
		var colon:Int = line.indexOf(":");
		if (colon == -1)
			throw new Exception("Invalid line: " + line);
		var i:Int = 0, lastMatch:Int = colon + 1;
		while(i < 3) {
			var comma:Int = line.indexOf(",", lastMatch);
			if (comma == -1) break;
			tuple[i] = trim(line.substr(lastMatch, comma - lastMatch));
			lastMatch = comma + 1;
			i++;
		}
		tuple[i] = trim(line.substring(lastMatch));
		return i + 1;
	}
}
