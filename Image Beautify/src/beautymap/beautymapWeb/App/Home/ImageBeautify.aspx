<%@ Page Language="C#" AutoEventWireup="true" Debug="true" %>

<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Drawing" %>
<script runat="server" lang="es-us" language="C#" type="text/C#">
    public static string ResizeBase64Image(String s){
        byte[] imageBytes = Convert.FromBase64String(s);
        System.Drawing.Image image = System.Drawing.Image.FromStream(new MemoryStream(imageBytes));
        double width = image.Width;
        double height = image.Height;
        double ratio = width / height;
        if(width > 400){
            width = 400;
            height = (int)(width / ratio);
        }
        
        if(height > 400)
        {
            height = 400;
            width = (int)(height * ratio);
        }
        Bitmap bitmap = ResizeImage(image, (int)width, (int)height);
        System.Drawing.Image im = (System.Drawing.Image)bitmap;
        string base64String = "";
        using (MemoryStream m = new MemoryStream())
        {
            im.Save(m, System.Drawing.Imaging.ImageFormat.Jpeg);
            imageBytes = m.ToArray();

            // Convert byte[] to Base64 String
            base64String = Convert.ToBase64String(imageBytes);
        }
        return base64String;
    }
    public static Bitmap ResizeImage(System.Drawing.Image image, int width, int height)
    {
        var destRect = new Rectangle(0, 0, width, height);
        var destImage = new Bitmap(width, height);

        destImage.SetResolution(image.HorizontalResolution, image.VerticalResolution);

        using (var graphics = Graphics.FromImage(destImage))
        {
            graphics.CompositingMode = System.Drawing.Drawing2D.CompositingMode.SourceCopy;
            graphics.CompositingQuality = System.Drawing.Drawing2D.CompositingQuality.HighQuality;
            graphics.InterpolationMode = System.Drawing.Drawing2D.InterpolationMode.HighQualityBicubic;
            graphics.SmoothingMode = System.Drawing.Drawing2D.SmoothingMode.HighQuality;
            graphics.PixelOffsetMode = System.Drawing.Drawing2D.PixelOffsetMode.HighQuality;

            using (var wrapMode = new System.Drawing.Imaging.ImageAttributes())
            {
                wrapMode.SetWrapMode(System.Drawing.Drawing2D.WrapMode.TileFlipXY);
                graphics.DrawImage(image, destRect, 0, 0, image.Width, image.Height, GraphicsUnit.Pixel, wrapMode);
            }
        }

        return destImage;
    }
    public static string GetUploadFileBase64(HttpRequest request)
    {
        HttpPostedFile postedFile = request.Files[0];
        if (postedFile == null)
            return "";
        try
        {
            string fileName = System.IO.Path.GetFileName(postedFile.FileName);
            string fileExtension = System.IO.Path.GetExtension(fileName);
            string dayTimeStr = System.DateTime.Now.Ticks.ToString();
            string storePath = @"d:\beautymap\beautymapWeb\App\Home\upload\" + dayTimeStr + fileExtension;
            postedFile.SaveAs(storePath);
            string base64String = "";
            using (System.Drawing.Image image = System.Drawing.Image.FromFile(storePath))
            {
                using (MemoryStream m = new MemoryStream())
                {
                    image.Save(m, image.RawFormat);
                    byte[] imageBytes = m.ToArray();

                    // Convert byte[] to Base64 String
                    base64String = Convert.ToBase64String(imageBytes);
                }
            }
            File.Delete(storePath);
            base64String = ResizeBase64Image(base64String);
            return "data:image;base64," + base64String;
        }
        catch (Exception e)
        {
            return e.Message;
        }
        finally
        {
        }
    }
</script>
<%
    string fn = Request.Params["fn"];
    if (fn == "uploadfile")
    {
        Response.Write(GetUploadFileBase64(Request));
        return;
    }
    else if (fn == "resizebase64image")
    {
        Response.Write(ResizeBase64Image(Request.Params["s"]));
        return;
    }

%>
<!DOCTYPE html>

<html lang="en" xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title>Image Beautify</title>
    <script src="https://appsforoffice.microsoft.com/lib/1/hosted/office.js" type="text/javascript"></script>
    <link href="../App.css" rel="stylesheet" type="text/css" />
    <script src="../App.js" type="text/javascript"></script>
    <script src="jquery-1.11.0.min.js"></script>
    <script src="uploadfile.js"></script>
    <script src="alloyimage-1.1.js"></script>
    <script src="home.js"></script>
    <script>
        var Page = {};
        Page.fileSelected = function () {
            var file = document.getElementById('fileToUpload').files[0];
            if (file) {
                var fileSize = 0;
                if (file.size > 1024 * 1024)
                    fileSize = (Math.round(file.size * 100 / (1024 * 1024)) / 100).toString() + 'MB';
                else
                    fileSize = (Math.round(file.size * 100 / 1024) / 100).toString() + 'KB';
                Page.startUploadFile(file.name);
            }
        };
        Page.startUploadFile = function (fileName) {
            var uploader = UPLOAD.create();
            uploader.fileName = fileName;
            uploader.containerid = "";
            uploader.formData.append("fileToUpload", document.getElementById('fileToUpload').files[0]);
            uploader.uploadURL = "ImageBeautify.aspx?fn=uploadfile";
            uploader.onUploadProgress = function (evt) {
                var loaded = evt.loaded;
                var total = evt.total;
                var percent = Math.round(loaded * 100 / total);
                $("#uploadpercenttext").text(percent + "%");
            };
            uploader.onUploadComplete = function (evt) {
                $("#uploadpercenttext").hide();
                var obj = evt.target.responseText;
                $("#showimagebox").empty();
                var img = document.createElement("img");
                img.src = obj;
                img.id = "myimage";
                img.onclick = function () {
                    insertImage(img.src);
                };
                var img1 = document.createElement("img");
                img1.src = obj;
                img1.id = "hiddenimage";
                img.onload = function () { Page.resizeImage() };
                $("#showimagebox").append(img);
                $("#showimagebox").append(img1);
                $("#hiddenimage").hide();
            }
            uploader.uploadFile();
        }
        Page.regEvent = function () {
            $("#uploadbtn").click(function () {
                $("#fileToUpload").trigger("click");
            });
            $("#selectbtn").click(function () {
                getImage();
            });
        };
        Page.resizeImage = function () {
            var ratio = $("#myimage").width() / $("#myimage").height();
            if ($("#myimage").height() > $(window).height() - 200) {
                $("#myimage").height($(window).height() - 200);
                $("#myimage").width($("#myimage").height() * ratio);
            }
            if ($("#myimage").width() > $(window).width() - 10) {
                $("#myimage").width($(window).width() - 10);
                $("#myimage").height($("#myimage").width() / ratio);
            }
            $("#myimage").parent("div").css("margin-left", 0 - ($("#myimage").width() / 2));
            $("#myimage").parent("div").css("margin-top", 0 - ($("#myimage").height() / 2));

        }
        $(document).ready(function () {
            refreshView();
            Page.regEvent();
        });

        function refreshView() {
            $("#imagebox").height($(window).height() - 100);
            setTimeout(refreshView, 200);
        }
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
        function insertImage(base64Img) {
            var b64 = base64Img.replace(/data.*?base64,/g, "");

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
        function getImage() {
            Office.context.document.getSelectedDataAsync(Office.CoercionType.Ooxml, function (res) {
                if (res.status === Office.AsyncResultStatus.Failed) {
                    console.log("Action failed with error: " + res.error.message);
                }
                else {
                    console.log(res.value);
                    var base64string = res.value.split("<pkg:binaryData>")[1].split("</pkg:binaryData>")[0];
                    getResizeBase64String(base64string);
                    
                }
            });
        }
        function getResizeBase64String(base64string) {
            $.ajax({
                type: "POST",
                url: "ImageBeautify.aspx?fn=resizebase64image",
                data: { s: base64string },
                success: function (obj) {
                    var newsrc = "data:image;base64," + obj;
                    $("#hiddenimage").attr("src", newsrc);
                    $("#myimage").attr("src", newsrc);
                },
                error: function () {
                }
            });
        }
    </script>
    <style>
        body {
            margin: 0;
            padding: 0;
        }

        .stylebox {
            width: 70px;
            height: 70px;
            background-color: #ffffff;
            cursor: pointer;
        }

        .styleimage {
            width: 90px;
            height: 60px;
            border-radius: 20px;
        }

        .styletext {
            position: absolute;
            bottom: 5px;
            right: 9px;
            text-shadow: 0 0 3px #000000;
            color: #ffffff;
        }

        #imageuploadprocessbox {
            position: absolute;
            top: 50%;
            left: 50%;
            margin-top: -31px;
            margin-left: -100px;
        }

        #imagebox {
            position: relative;
        }

        #showimagebox {
            position: absolute;
            top: 50%;
            left: 50%;
        }
    </style>
</head>
<body>
    <div id="headerbox" style="width: 100%; height: 100px; background-color: #ff6600">
        <div style="position: absolute; top: 0; left: 50%; margin-left: -125px; height: 100px;">
            <span style="line-height: 100px; font-size: 40px; color: #ffffff;">Image Beautify</span>
            <div style="position: absolute; top: 26px; right: -20px;">
                <img src="1.png" />
            </div>
        </div>
    </div>
    <div id="imagebox">
        <div id="selectbtn" style="float:left;width: 50%; height: 50px; background-color: #003366; cursor: pointer; position: relative;">
            <div style="position: absolute; top: 0; left: 50%; margin-left: -56px; height: 50px;">
                <span style="line-height: 50px; font-size: 16px; color: #ffffff;">Select Image File</span>
                <div style="position: absolute; top: 16px; left: -27px;">
                    
                </div>
            </div>
        </div>
        <div id="uploadbtn" style="float:left;width: 50%; height: 50px; background-color: #003366; cursor: pointer; position: relative;">
            <div style="position: absolute; top: 0; left: 50%; margin-left: -60px; height: 50px;">
                <span style="line-height: 50px; font-size: 16px; color: #ffffff;">Upload Image File</span>
                <div style="position: absolute; top: 16px; left: -27px;">
                    
                </div>
            </div>
        </div>
        <div style="clear:both;height:1px"></div>
        <div id="imageuploadprocessbox" style="display:none;"><span id="uploadpercenttext" style="line-height: 40px; font-size: 28px; text-shadow: 0 0 6px #000000; color: #ffffff;">No Image Selected</span></div>
        <div id="showimagebox">
            <img id="myimage" src="data:image/jpeg;base64,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" onload="Page.resizeImage()" onclick="insertImage(this.src)" />
            <img style="display:none" id="hiddenimage" src="data:image/jpeg;base64,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" />
        </div>
    </div>
    <div id="styleselectorbox" style="width: 100%; background-color: #003366; position: absolute; left: 0; bottom: 0; height: 90px; overflow-x: scroll; overflow-y: hidden;">
        <table style="width: 800px; display: block; border-collapse: collapse;">
            <tr>
                <td class="stylebox" onclick="updatePic('origin');">
                    <div style="position: relative;">
                        <img src="e1.jpg" class="styleimage" />
                        <span class="styletext">original</span>
                    </div>
                </td>
                <td class="stylebox" onclick="updatePic('softenFace');">
                    <div style="position: relative;">
                        <img src="e1.png" class="styleimage" />
                        <span class="styletext">beauty</span>
                    </div>
                </td>
                <td class="stylebox" onclick="updatePic('sketch');">
                    <div style="position: relative;">
                        <img src="e2.png" class="styleimage" />
                        <span class="styletext">sketch</span>
                    </div>
                </td>
                <td class="stylebox" onclick="updatePic('softEnhancement');">
                    <div style="position: relative;">
                        <img src="e3.png" class="styleimage" />
                        <span class="styletext">enhance</span>
                    </div>
                </td>
                <td class="stylebox" onclick="updatePic('purpleStyle');">
                    <div style="position: relative;">
                        <img src="e4.png" class="styleimage" />
                        <span class="styletext">strong</span>
                    </div>
                </td>
                <td class="stylebox" onclick="updatePic('soften');">
                    <div style="position: relative;">
                        <img src="e5.png" class="styleimage" />
                        <span class="styletext">smooth</span>
                    </div>
                </td>
                <td class="stylebox" onclick="updatePic('vintage');">
                    <div style="position: relative;">
                        <img src="e6.png" class="styleimage" />
                        <span class="styletext">old</span>
                    </div>
                </td>
                <td class="stylebox" onclick="updatePic('gray');">
                    <div style="position: relative;">
                        <img src="e7.png" class="styleimage" />
                        <span class="styletext">black</span>
                    </div>
                </td>
                <td class="stylebox" onclick="updatePic('lomo');">
                    <div style="position: relative;">
                        <img src="e8.png" class="styleimage" />
                        <span class="styletext">lomo</span>
                    </div>
                </td>
                <td class="stylebox" onclick="updatePic('strongEnhancement');">
                    <div style="position: relative;">
                        <img src="e9.png" class="styleimage" />
                        <span class="styletext">bright</span>
                    </div>
                </td>
                <td class="stylebox" onclick="updatePic('strongGray');">
                    <div style="position: relative;">
                        <img src="e10.png" class="styleimage" />
                        <span class="styletext">strongGray</span>
                    </div>
                </td>
                <td class="stylebox" onclick="updatePic('lightGray');">
                    <div style="position: relative;">
                        <img src="e11.png" class="styleimage" />
                        <span class="styletext">lightGray</span>
                    </div>
                </td>
                <td class="stylebox" onclick="updatePic('warmAutumn');">
                    <div style="position: relative;">
                        <img src="e12.png" class="styleimage" />
                        <span class="styletext">warm</span>
                    </div>
                </td>
                <td class="stylebox" onclick="updatePic('carveStyle');">
                    <div style="position: relative;">
                        <img src="e13.png" class="styleimage" />
                        <span class="styletext">wood</span>
                    </div>
                </td>
                <td class="stylebox" onclick="updatePic('rough');">
                    <div style="position: relative;">
                        <img src="e14.png" class="styleimage" />
                        <span class="styletext">rough</span>
                    </div>
                </td>
            </tr>
        </table>
    </div>
    <form id="form1" enctype="multipart/form-data" method="post" style="display: none;">
        <input type="file" class="btn1" name="fileToUpload" id="fileToUpload" onchange="Page.fileSelected();" />
    </form>
</body>
</html>
