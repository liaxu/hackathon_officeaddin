

onmessage = function (e) {
    var picTranseObj = e.data[0];
    if (e.data[1] != "origin") {
        picTranseObj = picTranseObj.ps(e.data[1]);
    }
    postMessage(picTranseObj);
}
