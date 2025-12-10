var inhibitionCookie = null;

function toggleCaffeine(on) {
    if (on) {
        // Request inhibition via KDE's org.freedesktop.PowerManagement
        inhibitionCookie = power.requestKeepAwake("user", "Caffeine Panel Icon");
        console.log("Caffeine enabled", inhibitionCookie);
    } else {
        if (inhibitionCookie !== null) {
            power.releaseKeepAwake(inhibitionCookie);
            inhibitionCookie = null;
            console.log("Caffeine disabled");
        }
    }
}
