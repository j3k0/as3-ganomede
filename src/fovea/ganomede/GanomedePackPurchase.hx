package fovea.ganomede;

import openfl.utils.Object;

@:expose
class GanomedePackPurchase {

    /* example packs:

    "packId": "...",

    "type": "ios-appstore",
    "iosTransactionId": "1000000121389",
    "iosAppStoreReceipt": "bAsE64jUnK"

    "type": "android-playstore",
    "playTransactionId": "1000000121389",
    "playSignature": "johndoe",
    "playSignedData": "bAsE64jUnK"

    "type": "claim",
    "claimReason": "win-single-player",
    "claimData": { ... }
    */

    public var packId:String;
    public var type:String;

    // ios
    public var iosTransactionId:String;
    public var iosAppStoreReceipt:String;

    // android
    public var playTransactionId:String;
    // public var playReceiptData:String;
    public var playSignature:String;
    public var playSignedData:String;

    // claim
    public var claimReason:String;
    public var claimData:String;

    public static inline var TYPE_IOS_APPSTORE:String = "ios-appstore";
    public static inline var TYPE_ANDROID_PLAYSTORE:String = "android-playstore";
    public static inline var TYPE_CLAIM:String = "claim";

    public function new(obj:Object = null) {
        fromJSON(obj);
    }

    public function fromJSON(obj:Object):Void {
        if (obj == null) return;
        if (obj.packId) packId = obj.packId;
        if (obj.type) type = obj.type;
        if (obj.iosTransactionId) iosTransactionId = obj.iosTransactionId;
        if (obj.iosAppStoreReceipt) iosAppStoreReceipt = obj.iosAppStoreReceipt;
        if (obj.playTransactionId) playTransactionId = obj.playTransactionId;
        // if (obj.playReceiptData) playReceiptData = obj.playReceiptData;
        if (obj.playSignature) playSignature = obj.playSignature;
        if (obj.playSignedData) playSignedData = obj.playSignedData;
        if (obj.claimReason) claimReason = obj.claimReason;
        if (obj.claimData) claimData = obj.claimData;
    }

    public function toJSON():Object {
        return {
            packId: packId,
            type: type,
            iosTransactionId: iosTransactionId,
            iosAppStoreReceipt: iosAppStoreReceipt,
            playTransactionId: playTransactionId,
            // playReceiptData: playReceiptData,
            playSignature: playSignature,
            playSignedData: playSignedData,
            claimReason: claimReason,
            claimData: claimData
        };
    }
}
// vim: sw=4:ts=4:et:
