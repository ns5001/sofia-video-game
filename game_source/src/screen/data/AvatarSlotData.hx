package screen.data;


// Holds the brushes available per-creature as a list.
class AvatarSlotData {
    private static var _faceColorOptions : Array<String> = [
        "face_color_1",
        "face_color_2",
        "face_color_3",
        "face_color_4",
        "face_color_5",
        "face_color_6",
        "face_color_7",
        "face_color_8",
    ];
    private static var _eyeShapeOptions : Array<String> = [
        "eyes_shape_1",
        "eyes_shape_2",
        "eyes_shape_3",
    ];
    private static var _glassesCircleOptions : Array<String> = [
        "glasses_circle_1",
        "glasses_circle_2",
        "glasses_circle_3",
        "glasses_circle_4",
        "glasses_circle_5",
        "glasses_circle_6",
        "glasses_circle_7",
        "glasses_circle_8",
    ];
    private static var _hearingAidOptions : Array<String> = [
        "hearingaid_1",
        "hearingaid_2",
        "hearingaid_3",
        "hearingaid_4",
        "hearingaid_5",
        "hearingaid_6",
        "hearingaid_7",
        "hearingaid_8",
    ];
    private static var _glassesSquareOptions : Array<String> = [
        "glasses_square_1",
        "glasses_square_2",
        "glasses_square_3",
        "glasses_square_4",
        "glasses_square_5",
        "glasses_square_6",
        "glasses_square_7",
        "glasses_square_8",
    ];
    private static var _capeOptions : Array<String> = [
        "cape_1",
        "cape_2",
        "cape_3",
        "cape_4",
        "cape_5",
        "cape_6",
        "cape_7",
        "cape_8",
    ];
    private static var _eyeColorOptions : Array<String> = [
        "eye_color_1",
        "eye_color_2",
        "eye_color_3",
        "eye_color_4",
        "eye_color_5",
        "eye_color_6",
        "eye_color_7",
        "eye_color_8",
        "eye_color_9",
        "eye_color_10",
        "eye_color_11",
        "eye_color_12",
    ];
    private static var _neckOptions : Array<String> = [
        "neck_color_1",
        "neck_color_2",
        "neck_color_3",
        "neck_color_4",
        "neck_color_5",
        "neck_color_6",
        "neck_color_7",
        "neck_color_8",
    ];
    private static var _hairOptions : Array<String> = [
        "hair_1_color_1",
        "hair_1_color_2",
        "hair_1_color_3",
        "hair_1_color_4",
        "hair_1_color_5",
        "hair_1_color_6",
        "hair_1_color_7",
        "hair_1_color_8",
        "hair_1_color_9",
        "hair_1_color_10",
        "hair_2_color_1",
        "hair_2_color_2",
        "hair_2_color_3",
        "hair_2_color_4",
        "hair_2_color_5",
        "hair_2_color_6",
        "hair_2_color_7",
        "hair_2_color_8",
        "hair_2_color_9",
        "hair_2_color_10",
        "hair_3_color_1",
        "hair_3_color_2",
        "hair_3_color_3",
        "hair_3_color_4",
        "hair_3_color_5",
        "hair_3_color_6",
        "hair_3_color_7",
        "hair_3_color_8",
        "hair_3_color_9",
        "hair_3_color_10",
        "hair_4_color_1",
        "hair_4_color_2",
        "hair_4_color_3",
        "hair_4_color_4",
        "hair_4_color_5",
        "hair_4_color_6",
        "hair_4_color_7",
        "hair_4_color_8",
        "hair_4_color_9",
        "hair_4_color_10",
        "hair_5_color_1",
        "hair_5_color_2",
        "hair_5_color_3",
        "hair_5_color_4",
        "hair_5_color_5",
        "hair_5_color_6",
        "hair_5_color_7",
        "hair_5_color_8",
        "hair_5_color_9",
        "hair_5_color_10",
        "hair_6_color_1",
        "hair_6_color_2",
        "hair_6_color_3",
        "hair_6_color_4",
        "hair_6_color_5",
        "hair_6_color_6",
        "hair_6_color_7",
        "hair_6_color_8",
        "hair_6_color_9",
        "hair_6_color_10",
        "hair_7_color_1",
        "hair_7_color_2",
        "hair_7_color_3",
        "hair_7_color_4",
        "hair_7_color_5",
        "hair_7_color_6",
        "hair_7_color_7",
        "hair_7_color_8",
        "hair_7_color_9",
        "hair_7_color_10",
        "hair_8_color_1",
        "hair_8_color_2",
        "hair_8_color_3",
        "hair_8_color_4",
        "hair_8_color_5",
        "hair_8_color_6",
        "hair_8_color_7",
        "hair_8_color_8",
        "hair_8_color_9",
        "hair_8_color_10",
        "hair_9_color_1",
        "hair_9_color_2",
        "hair_9_color_3",
        "hair_9_color_4",
        "hair_9_color_5",
        "hair_9_color_6",
        "hair_9_color_7",
        "hair_9_color_8",
        "hair_9_color_9",
        "hair_9_color_10",
        "hair_10_color_1",
        "hair_10_color_2",
        "hair_10_color_3",
        "hair_10_color_4",
        "hair_10_color_5",
        "hair_10_color_6",
        "hair_10_color_7",
        "hair_10_color_8",
        "hair_10_color_9",
        "hair_10_color_10",
        "hair_11_color_1",
        "hair_11_color_2",
        "hair_11_color_3",
        "hair_11_color_4",
        "hair_11_color_5",
        "hair_11_color_6",
        "hair_11_color_7",
        "hair_11_color_8",
        "hair_11_color_9",
        "hair_11_color_10",
        "hair_12_color_1",
        "hair_12_color_2",
        "hair_12_color_3",
        "hair_12_color_4",
        "hair_12_color_5",
        "hair_12_color_6",
        "hair_12_color_7",
        "hair_12_color_8",
        "hair_12_color_9",
        "hair_12_color_10",
        "hair_13_color_1",
        "hair_13_color_2",
        "hair_13_color_3",
        "hair_13_color_4",
        "hair_13_color_5",
        "hair_13_color_6",
        "hair_13_color_7",
        "hair_13_color_8",
        "hair_13_color_9",
        "hair_13_color_10",
        "hair_14_color_1",
        "hair_14_color_2",
        "hair_14_color_3",
        "hair_14_color_4",
        "hair_14_color_5",
        "hair_14_color_6",
        "hair_14_color_7",
        "hair_14_color_8",
        "hair_14_color_9",
        "hair_14_color_10",
        "hair_15_color_1",
        "hair_15_color_2",
        "hair_15_color_3",
        "hair_15_color_4",
        "hair_15_color_5",
        "hair_15_color_6",
        "hair_15_color_7",
        "hair_15_color_8",
        "hair_15_color_9",
        "hair_15_color_10",
        "hair_16_color_1",
        "hair_16_color_2",
        "hair_16_color_3",
        "hair_16_color_4",
        "hair_16_color_5",
        "hair_16_color_6",
        "hair_16_color_7",
        "hair_16_color_8",
        "hair_16_color_9",
        "hair_16_color_10",
        "hair_17_color_1",
        "hair_17_color_2",
        "hair_17_color_3",
        "hair_17_color_4",
        "hair_17_color_5",
        "hair_17_color_6",
        "hair_17_color_7",
        "hair_17_color_8",
        "hair_17_color_9",
        "hair_17_color_10",
        "hair_18_color_1",
        "hair_18_color_2",
        "hair_18_color_3",
        "hair_18_color_4",
        "hair_18_color_5",
        "hair_18_color_6",
        "hair_18_color_7",
        "hair_18_color_8",
        "hair_18_color_9",
        "hair_18_color_10",
        "hair_19_color_1",
        "hair_19_color_2",
        "hair_19_color_3",
        "hair_19_color_4",
        "hair_19_color_5",
        "hair_19_color_6",
        "hair_19_color_7",
        "hair_19_color_8",
        "hair_19_color_9",
        "hair_19_color_10",
        "hair_20_color_1",
        "hair_20_color_2",
        "hair_20_color_3",
        "hair_20_color_4",
        "hair_20_color_5",
        "hair_20_color_6",
        "hair_20_color_7",
        "hair_20_color_8",
        "hair_20_color_9",
        "hair_20_color_10",
    ];
    private static var _hairBackOptions : Array<String> = [
        "hair_10_color_1_back",
        "hair_10_color_2_back",
        "hair_10_color_3_back",
        "hair_10_color_4_back",
        "hair_10_color_5_back",
        "hair_10_color_6_back",
        "hair_10_color_7_back",
        "hair_10_color_8_back",
        "hair_10_color_9_back",
        "hair_10_color_10_back",
        "hair_14_color_1_back",
        "hair_14_color_2_back",
        "hair_14_color_3_back",
        "hair_14_color_4_back",
        "hair_14_color_5_back",
        "hair_14_color_6_back",
        "hair_14_color_7_back",
        "hair_14_color_8_back",
        "hair_14_color_9_back",
        "hair_14_color_10_back",
        "hair_15_color_1_back",
        "hair_15_color_2_back",
        "hair_15_color_3_back",
        "hair_15_color_4_back",
        "hair_15_color_5_back",
        "hair_15_color_6_back",
        "hair_15_color_7_back",
        "hair_15_color_8_back",
        "hair_15_color_9_back",
        "hair_15_color_10_back",
    ];
    private static var _maskOptions : Array<String> = [
        "mask_1",
        "mask_2",
        "mask_3",
        "mask_4",
        "mask_5",
        "mask_6",
        "mask_7",
        "mask_8",
    ];
    private static var _eyeColor2Options : Array<String> = [
        "eye_color_1",
        "eye_color_2",
        "eye_color_3",
        "eye_color_4",
        "eye_color_5",
        "eye_color_6",
        "eye_color_7",
        "eye_color_8",
        "eye_color_9",
        "eye_color_10",
        "eye_color_11",
        "eye_color_12",
    ];

    public static function getSlotAttachment(pSlotName : String, pIndex : Int) : String {
        switch (pSlotName) {
            case "face_color" :
                return _faceColorOptions[pIndex];
            case "eyes_shape" :
                return _eyeShapeOptions[pIndex];
            case "glasses_circle" :
                return _glassesCircleOptions[pIndex];
            case "hearingaid" :
                return _hearingAidOptions[pIndex];
            case "glasses_square" :
                return _glassesSquareOptions[pIndex];
            case "cape" :
                return _capeOptions[pIndex];
            case "eye_color" :
                return _eyeColorOptions[pIndex];
            case "neck" :
                return _neckOptions[pIndex];
            case "hair" :
                return _hairOptions[pIndex];
            case "hair_back" :
                return _hairBackOptions[pIndex];
            case "mask" :
                return _maskOptions[pIndex];
            case "eye_color2" :
                return _eyeColor2Options[pIndex];
            default :
                return _faceColorOptions[pIndex];
        }
    }

    public static function getDefinitionData(pWord : String) : Dynamic {
        switch(pWord) {
            case "check-ups":
                return {word: "Check-ups", x1: -400, y1: 0, definition: "This is where the definition would go", x2: 30, y2: 0};
            case "medicine":
                return {word: "Medicine", x1: -400, y1: 0, definition: "Something your parent or doctor might give you to\n make you feel better when you're sick.", x2: 0, y2: 0};
            default:
                return {word: "Check-ups", x1: 0, y1: 0, definition: "This is where the definition would go", x2: 30, y2: 0};
        }
    }

    public static function getHairAttachment(pStyleIndex : Int, pColorIndex : Int) : String {
        return "hair_" + (pStyleIndex+1) + "_color_" + (pColorIndex+1);
    }

    public static function getHairBackAttachment(pStyleIndex : Int, pColorIndex : Int) : String {
        return "hair_" + (pStyleIndex+1) + "_color_" + (pColorIndex+1) + "_back";
    }
}