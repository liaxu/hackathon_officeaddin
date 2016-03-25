/// <reference path="../App.js" />

(function () {
    "use strict";

    // The initialize function must be run each time a new page is loaded
    Office.initialize = function (reason) {
        $(document).ready(function () {
            app.initialize();

            $('.get-data-from-selection').click(getDataFromSelection);
        });
    };

    // Reads data from current document selection and displays a notification
    function getDataFromSelection() {
        Office.context.document.getSelectedDataAsync(Office.CoercionType.Matrix,
            {valueFormat: Office.ValueFormat.Unformatted},
            function (result) {
                if (result.status === Office.AsyncResultStatus.Succeeded) {
                    var finalData;
                    finalData = result.value;

                    Office.context.document.getSelectedDataAsync(Office.CoercionType.Matrix, {valueFormat: Office.ValueFormat.Formatted},
                        function (result) 
                        {
                            if(result.status === Office.AsyncResultStatus.Succeeded) {
                                finalData = result.value;
                                callback(finalData);
                                var element = $('.mh-field mh-year');

                                _loader.remove && _loader.remove("rili-widget");
                                _loader.add("rili-widget", "./js/wnl.js");//上述JS文件们已让我压缩成wnl.js
                                _loader.use("jquery, rili-widget", function () {
                                var RiLi = window.OB.RiLi;

                                var gMsg = RiLi.msg_config,
                                    dispatcher = RiLi.Dispatcher,
                                    mediator = RiLi.mediator;

                                var root = window.OB.RiLi.rootSelector || '';

                                // RiLi.AppData(namespace, signature, storeObj) 为了解决"In IE7, keys may not contain special chars"
                                //'api.hao.360.cn:rili' 仅仅是个 namespace
                                var timeData = new RiLi.AppData('api.hao.360.cn:rili'),
                                    gap = timeData.get('timeOffset'),
                                    dt = new Date(new Date() - (gap || 0));

                                RiLi.action = "default";

                                var $detail = $(root + '.mh-almanac .mh-almanac-main');
                                $detail.dayDetail(dt);

                                var returnResult = result.value.toString();
                                var from = returnResult.split("/");
                                if (from!= "" && from.length == 3)
                                {
                                    var f = new Date(from[2], from[0] - 1, from[1]);
                                    RiLi.today = f;
                                    RiLi.needDay = f;
                                    var $wbc = $(root + '.mh-calendar');
                                    $wbc.webCalendar("initTime", RiLi.needDay || RiLi.today);

                                    $('.mh-year').attr('val', from[2]);
                                    $('.mh-year').text(from[2] + '年');
                                    $('.mh-month').attr('val', from[0]);
                                    $('.mh-month').text(from[0] + '月');
                                }
                                else
                                {
                                    return;
                                }
                                });
                            }
                            else
                            {
                                callback(null);
                            }
                        }
            );
                }
            });
    }
})();

