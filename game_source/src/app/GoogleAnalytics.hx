package app;

class GoogleAnalytics {

    public static function LogEvent(pName : String, pParams : Dynamic = null) : Void {
        if (pParams != null) {
            untyped {
                gtag("event", pName, pParams);
            }
        } else {
            untyped {
                gtag("event", pName);
            }
        }
    }
}