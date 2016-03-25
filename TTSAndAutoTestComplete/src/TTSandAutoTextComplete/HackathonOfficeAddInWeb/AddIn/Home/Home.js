/// <reference path="../App.js" />

(function () {
    "use strict";

    // The initialize function must be run each time a new page is loaded
    Office.initialize = function (reason) {
        $(document).ready(function () {
            app.initialize();
            var recordList = document.createElement("select");
            recordList.setAttribute("id", "recordList");
            recordList.setAttribute("size", "15");
            recordList.setAttribute("class", "dictionary");
            var recordArea = document.getElementById("recordArea");
            recordArea.appendChild(recordList);
            $("#recordList").dblclick(insertSelectedRecord);
            $('#record-selected-data').click(recordSelectedData);
            $('#match-selected-data').click(matchSelectedData);
            $('#insert-selected-record').click(insertSelectedRecord);
            $('#voiceReadSelection').click(getVoiceData);
        });
    };

    function sortNumber(a, b) {
        var aa = new String(a);
        var bb = new String(b);
        return aa.localeCompare(bb);
    }

    // Send request to Baidu to get the voice data
    function getVoiceData() {
        Office.context.document.getSelectedDataAsync(Office.CoercionType.Text,
            function (result) {
                if (result.status === Office.AsyncResultStatus.Succeeded) {
                    if (result.value == null || result.value == "")
                        return;

                    document.getElementById("myFrame").src = "WebForm1.aspx?textData=" + result.value;
                } else {
                    app.showNotification('Error:', result.error.message);
                }
            }
        );
    }

    function matchSelectedData() {
        Office.context.document.getSelectedDataAsync(Office.CoercionType.Text,
        function (result) {
            if (result.status === Office.AsyncResultStatus.Succeeded) {
                var getrecordList;
                getrecordList = document.getElementById("recordList");
                var options = getrecordList.getElementsByTagName("option");

                for (var i = 0; i < options.length; i++) {
                    var optionValue = options[i].value;
                    if (optionValue.toLowerCase().startsWith(result.value.toString().toLowerCase().trim())) {
                        options[i].setAttribute("selected", true);
                        break;
                    }
                }
            } else {
                app.showNotification('Error:', result.error.message);
            }
        }
    );
    }

    function recordSelectedData() {
        Office.context.document.getSelectedDataAsync(Office.CoercionType.Text,
            function (result) {
                if (result.status === Office.AsyncResultStatus.Succeeded) {
                    var recordList = document.getElementById("recordList");
                    var arr = new Array();
                    var options = recordList.getElementsByTagName("option");
                    var ln = options.length;
                    for (var i = 0; i < ln; i++) {
                        if (result.value.toString().trim() == options[i].value) {
                            return;
                        }
                        arr[i] = options[i].value;
                    }
                    arr[options.length] = result.value.toString().trim();
                    arr.sort(sortNumber);

                    while (ln-- > 0) {
                        recordList.removeChild(recordList.childNodes[0]);
                    }
                    for (i = 0; i < arr.length; i++) {
                        var option = document.createElement("option");
                        var txt = document.createTextNode(arr[i]);
                        option.appendChild(txt);
                        recordList.appendChild(option);
                    }
                } else {
                    app.showNotification('Error:', result.error.message);
                }
            }
        );
    }

    function insertSelectedRecord() {

        Office.context.document.setSelectedDataAsync($("#recordList option:selected").text(),
            function (result) {
                if (result.status === Office.AsyncResultStatus.Failed) {
                    app.showNotification('Error:', result.error.message);
                }
            }
        );
    }
})();