async function detectandsecureurl() {
    try {
        // Fetch the configuration JSON
        const response = await fetch('https://raw.githubusercontent.com/DrMineword/Artefact-Boost-Active/refs/heads/main/redirect/autoscript/config.json');
        const config = await response.json();

        // Log the analyzed version of the config JSON to the console
        console.log("Analyzed config JSON:", JSON.stringify(config, null, 2));

        // Extract configuration parameters
        const whitelistedDomains = config.whitelistedDomains || [];
        const rundomains = config.rundomains || ["*//*"];
        const redirectBaseUrl = "https://drmineword.github.io/Artefact-Boost-Active/redirect/url";
        const defaultBackground = config.background || "";
        const defaultTime = config.time || 6;

        // Helper function to check if the script should run on the current domain
        function isRunDomainAllowed(currentDomain, runDomains) {
            return runDomains.some(pattern => {
                // If the pattern is '*//*', treat it as a wildcard allowing any domain
                if (pattern === "*//*") {
                    return true;  // Allow all domains
                }

                // Convert other wildcard patterns (e.g., *.example.com) into regex to match domains
                const regexPattern = `^${pattern.replace(/\*/g, '.*')}$`; 
                const regex = new RegExp(regexPattern);
                return regex.test(currentDomain);
            });
        }

        // Helper function to check if a URL matches a whitelist pattern
        function isUrlWhitelisted(url, whitelist) {
            return whitelist.some(pattern => {
                // Handle wildcard at the end of the domain (e.g., example.com/*)
                const regexPattern = `^${pattern.replace(/\*/g, '.*')}$`;
                const regex = new RegExp(regexPattern);
                return regex.test(url);
            });
        }

        // Check if the script should run on the current domain
        const currentDomain = window.location.hostname;
        if (!isRunDomainAllowed(currentDomain, rundomains)) {
            console.log(`Script not allowed to run on this domain: ${currentDomain}`);
            return;
        }

        // Get all anchor tags in the document
        const anchorTags = document.querySelectorAll('a[href]');

        let unsafeUrlsDetected = false;  // To track if any unsafe URL is detected
        const logs = [];  // Array to store log objects for console output

        anchorTags.forEach(anchor => {
            const href = anchor.href;
            const domain = new URL(href).hostname;

            // Check if the domain is in the whitelist
            if (isUrlWhitelisted(href, whitelistedDomains)) {
                // Log that the URL is kept
                logs.push({ link: href, action: "keep" });
            } else {
                // Prepare redirect URL
                const name = config.name.replace("{domain}", domain);
                const redirectUrl = `${redirectBaseUrl}?background=${encodeURIComponent(defaultBackground)}&time=${defaultTime}&name=${encodeURIComponent(name)}&url=${encodeURIComponent(href)}`;

                // Update the anchor href
                anchor.href = redirectUrl;

                // Log the transformation to console
                logs.push({ link: href, action: "edit" });
                unsafeUrlsDetected = true;  // Mark unsafe URL detection
            }
        });

        // Output the log actions in the console
        logs.forEach(log => {
            console.log(JSON.stringify(log));
        });

        // If no unsafe URLs were detected, log that as well
        if (!unsafeUrlsDetected) {
            console.log("No unsafe URLs detected on this page.");
        }
    } catch (error) {
        console.error('Error processing whitelist script:', error);
    }
}

// Run the function automatically after the page is fully loaded
window.addEventListener('load', detectandsecureurl);


detectandsecureurl()
