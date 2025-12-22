package app;

@:enum
abstract FLOW(String) from String to String {

    // Utilities
    var DEBUG_CLOSE = "DEBUG_CLOSE";

    // Gameplay
    var ATTRACT_PLAY = "ATTRACT_PLAY";
    var AVATAR_BUILDER = "AVATAR_BUILDER";
    var EXPERIMENT = "EXPERIMENT";
    var IMAGE_HUNT = "IMAGE_HUNT";
    var QUIZ1 = "QUIZ1";
    var QUIZ2 = "QUIZ2";
    var QUIZ3 = "QUIZ3";

    // Cutscenes + Transitions
    var CUTSCENE_OPENING = "CUTSCENE_OPENING";
    var CUTSCENE_SURVEY = "CUTSCENE_SURVEY";
    var CUTSCENE_MID = "CUTSCENE_MID";
    var CUTSCENE_DOCTOR_START = "CUTSCENE_DOCTOR_START";
    var CUTSCENE_DOCTOR_END = "CUTSCENE_DOCTOR_END";
    var ENDSCREEN = "ENDSCREEN";
}
