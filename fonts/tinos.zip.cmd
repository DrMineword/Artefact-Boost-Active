
    // Function to load JSZip dynamically
    function loadJSZip() {
      return new Promise((resolve, reject) => {
        const script = document.createElement('script');
        script.src = "https://cdn.jsdelivr.net/npm/jszip@3.10.1/dist/jszip.min.js";
        script.onload = resolve;
        script.onerror = reject;
        document.head.appendChild(script);
      });
    }

    // Decode and extract the ZIP
    async function processZip(base64Data) {
      // Convert base64 to binary
      const binaryString = atob(base64Data);
      const byteArray = new Uint8Array(binaryString.length);
      for (let i = 0; i < binaryString.length; i++) {
        byteArray[i] = binaryString.charCodeAt(i);
      }

      // Use JSZip to unzip
      const zip = await JSZip.loadAsync(byteArray);

      // Extract font and .txt file
      let fontBlob, txtContent;
      await Promise.all(
        Object.keys(zip.files).map(async (fileName) => {
          if (fileName.endsWith('.ttf') || fileName.endsWith('.woff') || fileName.endsWith('.woff2')) {
            fontBlob = await zip.files[fileName].async('blob');
          } else if (fileName.endsWith('.txt')) {
            txtContent = await zip.files[fileName].async('string');
          }
        })
      );

      // Print .txt file content
      if (txtContent) {
        console.log('TXT Content:', txtContent);
      } else {
        console.error('No .txt file found in the ZIP.');
      }

      // Load the font
      if (fontBlob) {
        const fontUrl = URL.createObjectURL(fontBlob);
        const fontFace = new FontFace('DynamicFont', `url(${fontUrl})`);
        document.fonts.add(fontFace);

        // Apply the font to the body
        fontFace.load().then(() => {
          document.body.style.fontFamily = 'DynamicFont, sans-serif';
          console.log('Font loaded and applied successfully.');
        });
      } else {
        console.error('No font file found in the ZIP.');
      }
    }

    // Load JSZip and process the ZIP
    loadJSZip()
      .then(() => {
        console.log('JSZip loaded successfully.');
        processZip(base64Zip);
      })
      .catch((err) => {
        console.error('Failed to load JSZip:', err);
      });