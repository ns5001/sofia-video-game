package app;

import workinman.WMSaving;
import haxe.crypto.BaseCode;
import haxe.crypto.Base64;
import haxe.io.BytesData;
import haxe.io.Bytes;
import js.html.Uint8ClampedArray;
import js.html.Image;
import js.html.ImageBitmap;
import app.ConstantsApp;

class SaveData{

  static private var __instance:SaveData;
  static public var instance( get, never ):SaveData;

  static private function get_instance():SaveData {
    if (__instance == null) {
      __instance = new SaveData();
    }
    return __instance;
  }

  private var _saveData:Array<PaintSaveData>;

  public function new() {
    _saveData = new Array<PaintSaveData>();

    // Create data slots for the max number of drawings we support.
    for( d in 0...(ConstantsApp.HABITAT_COUNT * ConstantsApp.MAX_DRAWINGS_PER_HABITAT) ) {
        _saveData.push(new PaintSaveData());
    }
  }

  public function getData(slot:Int):PaintSaveData {

    return _saveData[slot];
  }

  public function deleteSlot(slot:Int){
    if(slot < 0 || slot >= _saveData.length){
      trace("[SaveData] (deleteSlot) index out of bounds: " + slot);
      return;
    }

    _saveData[slot] = null;
    save();
  }

  public function save(){
    trace("[SaveData] Saving data...");
    var data:Dynamic = {};

    for(i in 0..._saveData.length){
      _saveData[i].exportSaveData(i, data);
    }

    WMSaving.dataSave(ConstantsApp.SAVE_STRING, data);
  }

  public function delete(){
    trace("[SaveData] (delete)");
		WMSaving.dataDelete(ConstantsApp.SAVE_STRING);
	}

  public function load(){
    var data:Dynamic = WMSaving.dataLoad(ConstantsApp.SAVE_STRING);

    for(i in 0...ConstantsApp.MAX_DRAWINGS_PER_HABITAT * ConstantsApp.HABITAT_COUNT) {
        untyped {
            if(data["paintData_" + Std.string(i)] != null) {
                _saveData[i] = _buildSaveFromData(i, data);
            }
        }
    }
  }

  private function _buildSaveFromData(i:Int, data:Dynamic):PaintSaveData{
    var save:PaintSaveData;
    untyped{
      save = new PaintSaveData();
      save.importSaveData(i, data);
    }

    return save;
  }
}

// Data that stores painting info
class PaintSaveData{
  public var paintData:Bytes;
  public var paintDataBuffer:String = null;
  public var paintDataImage:Image;
  public var paintDataBitmap:ImageBitmap;

  public function new(pPaintData:Bytes=null){
    paintData = pPaintData;
  }

  public function importSaveData(i:Int, data:Dynamic){
    var savedPaintDataString = "none";

    untyped{
      savedPaintDataString = data["paintData_" + Std.string(i)];
      if(savedPaintDataString != null){
        paintData = _decodeHex( savedPaintDataString );
      }
    }
  }

  public function exportSaveData(i:Int, data:Dynamic){
    var paintDataString:String = null;

    if(paintData != null){
      paintDataString = paintData.toHex();
    }

    untyped{
      data["paintData_" + Std.string(i)] = paintDataString;
    }
  }

  private function _decodeHex(str:String):Bytes{
    var base = Bytes.ofString("0123456789abcdef");
    return new BaseCode(base).decodeBytes(Bytes.ofString(str.toLowerCase()));
  }
}
