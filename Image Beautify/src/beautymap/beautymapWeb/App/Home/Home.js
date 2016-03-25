/// <reference path="../App.js" />

(function () {
    "use strict";

    Office.initialize = function (reason) {
        $(document).ready(function () {
            app.initialize();

            //$("#writeDataBtn").click(function (event) {
            //    updatePic("rough");
            //    //updatePic("purpleStyle");
            //});
            //$("#readDataBtn").click(function (event) {
            //    updatePic("lomo");
            //});

            //$("#bindDataBtn").click(function (event) {
            //    updatePic("rough");
            //});

        });
    };

    function test() {
        if (window.Worker) {
            alert("s");
        }
    }

    //updatePic("softenFace");
    //updatePic("sketch");
    //updatePic("softEnhancement");
    //updatePic("purpleStyle");
    //updatePic("soften");
    //updatePic("vintage");
    //updatePic("gray");
    //updatePic("lomo");
    //updatePic("strongEnhancement");
    //updatePic("strongGray");
    //updatePic("lightGray");
    //updatePic("warmAutumn");
    //updatePic("carveStyle");
    //updatePic("rough");
    //updatePic("origin");
    function updatePic(picStyle) {
        var pic = document.getElementById("hiddenimage");
        var showPic = document.getElementById("myimage");

        var picTranseObj = $AI(pic);

        //workerMethods(picTranseObj, picStyle);

        if (picStyle != "origin") {
            picTranseObj = picTranseObj.ps(picStyle);
        }
        picTranseObj.replace(showPic);
    }

    function workerMethods(aiObj,picStyle) {
        var myWorker = new Worker("worker.js");
        myWorker.postMessage([aiObj, picStyle]);

        myWorker.onmessage = function (e) {
            result.textContent = e.data;
            console.log('Message received from worker');
        }
    }

    function readData() {
        Office.context.document.getSelectedDataAsync(Office.CoercionType.Ooxml,
            function (result) {
                if (result.status === Office.AsyncResultStatus.Succeeded) {
                    //app.showNotification('选定的文本为:', '"' + result.value + '"');
                    alert(result.value);
                } else {
                    //app.showNotification('错误:', result.error.message);
                    alert(result.error.message);
                }
            }
        );
    }


    function insertImage(base64Img) {
        var b64 = base64Img.replace("data:;base64,", "");

        Office.context.document.setSelectedDataAsync(b64, {
            coercionType: Office.CoercionType.Image,
            imageTop: 100,
            imageLeft: 100
        },
        function (asyncResult) {
            if (asyncResult.status === Office.AsyncResultStatus.Failed) {
                console.log("Action failed with error: " + asyncResult.error.message);
            }
        });
    }

    function writeToPage(text) {
        document.getElementById('results').innerText = text;
    }
})();