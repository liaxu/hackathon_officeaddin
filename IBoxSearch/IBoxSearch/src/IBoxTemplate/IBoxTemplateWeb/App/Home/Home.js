/// <reference path="../App.js" />

var currentSection = "";

(function () {
    "use strict";

    // The initialize function must be run each time a new page is loaded
    Office.initialize = function (reason) {
        $(document).ready(function () {
            app.initialize();

            $.get("IBox/SectionList.html", null, function (data) {
                $('#section-list').val(data);
            }, "html");

            $('#get-ibox-template').click(function () {
                getAutoSearchResult();
            });
        });

        var _doc = Office.context.document;
        _doc.addHandlerAsync(Office.EventType.DocumentSelectionChanged, function () {
            getHeading();

        });
    }


    // Gets the heading from the selected range
    function getHeading() {
        Word.run(function (context) {
            var range = context.document.getSelection();
            var paras = range.paragraphs;
            context.load(paras);

            return context.sync().then(function () {

                var para = paras.items[0];
                if (para.style != "Normal") {
                    var heading = para.text;
                    var delimiter = heading.indexOf("\t");
                    var headingNum = heading.substring(0, delimiter);
                    $('#sectionID').val(headingNum);


                    if ($("#sectionID").val() != currentSection) {
                        setTimeout(function () { getAutoSearchResult() }, 0);
                    }

                }

            });
        })
        .catch(function (error) {
            console.log('Error: ' + JSON.stringify(error));
            if (error instanceof OfficeExtension.Error) {
                console.log('Debug info: ' + JSON.stringify(error.debugInfo));
            }
        });

    };

})();

//Auto Search
function getAutoSearchResult() {

    currentSection = $('#sectionID').val();
    app.showNotification('The section number is : ' + currentSection);

    var list = jQuery.parseJSON($('#section-list').val());
    var template = "SOAP";
    var selSection = null;

    for (var i = 0; ; i++) {
        var temp = list[i];
        if (temp == null) {
            break;
        }
        if (temp.Template == template) {
            var sections = JSON.stringify(temp.Sections).replace("\"", "").replace("\"", "").split(" ");
            for (var j = 0; j < sections.length; j++) {
                if (sections[j] == currentSection) {
                    selSection = currentSection;
                    break;
                }
                if (sections[j].indexOf("x", 0) > 0) {
                    var temp = sections[j];
                    temp = temp.replace("x", "[1-9]\d*");
                    temp = temp.replace("y", "[1-9]\d*");
                    temp = temp.replace("z", "[1-9]\d*");
                    temp = "/^" + temp + "$/";
                    var reg = eval(temp);
                    if (reg.test(currentSection)) {
                        selSection = sections[j];
                        break;
                    }
                }
            }
            break;
        }
    }

    var resourceUrl = "IBox/" + template + "_section_" + selSection + ".html";

    $.get(resourceUrl, null, function (data) {
        $('#ibox-content').html(data);
    }, "html");

    if (selSection == null) {
        app.showNotification('"' + currentSection + '"' + ' is not found for ' + template + ' template.');
        $('#ibox-content').html(null);
    }
}