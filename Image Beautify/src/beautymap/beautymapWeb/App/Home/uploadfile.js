var UPLOADFILE = {};
UPLOADFILE.uploaderArray = new Array();
UPLOADFILE.instance = function(fileToken){
    for(var i = 0; i < this.uploaderArray.length; i++){
        if(this.uploaderArray[i].fileToken == fileToken){
            return this.uploaderArray[i];
        }
        return null;
    }
};
var UPLOAD = {
	create:function(){
		var uploader = {};
		uploader.containerid = "";
		uploader.fileName = "";
		uploader.fileToken = getRandString(16);
		uploader.formData = new FormData();;
		uploader.uploadURL = "";
		uploader.onUploadComplete = function(evt){
			var obj = $.parseJSON(evt.target.responseText);
			var fileid = obj.ReturnValue;
			$("#" + uploader.fileToken).attr("fileid", fileid);
            $()
		};
		uploader.deleteFile = null;
		uploader.onUploadFailed = null;
		uploader.onUploadCanceled = null;
		uploader.onUploadProgress = function(evt){
			if (evt.lengthComputable) {
				var loaded = evt.loaded;
				var total = evt.total;
				var percent = Math.round(loaded * 100 / total);
				if($("#" + uploader.fileToken).length == 0){
				    var html = '<li fileid="" id="' + uploader.fileToken + '" class="griditem" name="fileitem" style="position:relative;"><div class="uploadfilenamebox"><span>' + uploader.fileName + '</span></div><div class="uploadprogressbox"><span>' + percent + '%</span></div><span style="font-family: ykuiFont;font-size: 10px;position:absolute;top:-14px;right:-5px;" id="deletefilebtn'+uploader.fileToken+'">I</span></li>';
				    $(html).insertBefore("#addfilebtn");
				    $("#deletefilebtn" + uploader.fileToken).click(function () {
				        uploader.deleteFile($(this));
				    });
				}
				else{
					$("#" + uploader.fileToken).find(".uploadprogressbox").find("span").text(percent + "%");
				}
			}
			else {
			}
		};
		uploader.uploadFile = function(){
			var xhr = new XMLHttpRequest();
			xhr.upload.addEventListener("progress", this.onUploadProgress, false);
			xhr.addEventListener("load", this.onUploadComplete, false);
			xhr.addEventListener("error", this.onUploadFailed, false);
			xhr.addEventListener("abort", this.onUploadCanceled, false);
			xhr.open("POST", this.uploadURL);
			xhr.send(this.formData);
		};
		
		UPLOADFILE.uploaderArray.push(uploader);
		return uploader;
	}
}

function getRandString(count){
    var randStr = "";
    var arr = ["0","1","2","3","4","5","6","7","8","9","a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"];
    for(var i = 0; i<count; i++){
        var r = Math.floor(Math.random() * 36);
        randStr = randStr + arr[r];
    }
    return randStr;
}
function loadStyleStrings(){
	loadStyleString(".uploadfilenamebox:width:200px;");
	loadStyleString(".uploadprogressbox:width:200px;");
}

function loadStyleString(css){
    var style = document.createElement("style");
    style.type = "text/css";
    try{
        style.appendChild(document.createTextNode(css))
    }catch(ex){
        style.styleSheet.cssText = css;
    }
    var head = document.getElementsByTagName("head")[0];
    head.appendChild(style);
}