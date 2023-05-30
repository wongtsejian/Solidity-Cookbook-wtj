function generateFilename(fnName) {
    const now = new Date();
    const date = now.getDate().toString().padStart(2, '0');
    const month = (now.getMonth() + 1).toString().padStart(2, '0'); // Months are zero-based
    const year = now.getFullYear().toString();
    const time = now.toLocaleTimeString([], { hour12: false }).replace(/:/g, ''); // Remove colons from the time
  
    return `tx-${fnName}-${date}-${month}-${year}_${time}.json`;
  }
  
  module.exports = generateFilename;
  
  