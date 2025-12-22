package workinman.display.spine.attachments;

class AttachmentType {
	
	public static inline var region:String = "region";
	public static inline var regionsequence:String = "regionsequence";
	public static inline var boundingbox:String = "boundingbox";
	public static inline var mesh:String = "mesh";
	public static inline var weightedmesh:String = "weightedmesh";

	public var ordinal:Int;
	public var name:String;

	public function new (ordinal:Int, name:String) {
		this.ordinal = ordinal;
		this.name = name;
	}
}
