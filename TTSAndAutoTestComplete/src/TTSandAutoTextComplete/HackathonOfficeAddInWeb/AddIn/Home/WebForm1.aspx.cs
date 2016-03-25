using System;
using System.Net;
using System.Text;
using System.IO;

namespace HackathonOfficeAddInWeb.AddIn.Home
{
    public partial class WebForm1 : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            String data = Request.QueryString["textData"];
            if (data == null)
                return;

            if (Application["Token"] == null)
            {
                Application["Token"] = RequestAccessToken();
            }

            RequestVoiceData(data);
        }

        private String RequestAccessToken()
        {
            String url = "https://openapi.baidu.com/oauth/2.0/token";

            HttpWebRequest request = (HttpWebRequest)HttpWebRequest.Create(url);
            Encoding encoding = Encoding.UTF8;

            request.ContentType = "application/x-www-form-urlencoded";
            request.Method = "POST";
            String param = "grant_type=client_credentials&client_id=MDvc1jjRt3thYytefsLDekmK&client_secret=1e6a12a997748f45b7e28f1d41858de4";
            byte[] bs = Encoding.ASCII.GetBytes(param);
            request.ContentLength = bs.Length;
            using (Stream reqStream = request.GetRequestStream())
            {
                reqStream.Write(bs, 0, bs.Length);
                reqStream.Close();
            }

            string responseData = String.Empty;
            using (HttpWebResponse response = (HttpWebResponse)request.GetResponse())
            {
                using (StreamReader reader = new StreamReader(response.GetResponseStream(), encoding))
                {
                    responseData = reader.ReadToEnd().ToString();
                    String result = responseData.Remove(0, responseData.IndexOf(":") + 1);
                    result = result.Substring(0, result.IndexOf(","));
                    result = result.TrimStart('"');
                    result = result.TrimEnd('"');
                    return result;
                }
            }
        }

        private void RequestVoiceData(String data)
        {
            myAudio.InnerHtml = "";

            String url = "http://tsn.baidu.com/text2audio";

            HttpWebRequest request = (HttpWebRequest)HttpWebRequest.Create(url);
            Encoding encoding = Encoding.UTF8;

            request.ContentType = "application/x-www-form-urlencoded";
            request.Method = "POST";
            String param = "tex=" + data;
            param += "&lan=zh&cuid=08-10-78-55-64-93&ctp=1";
            param += "&tok=" + Application["Token"];

            byte[] bs = Encoding.UTF8.GetBytes(param);
            request.ContentLength = bs.Length;
            using (Stream reqStream = request.GetRequestStream())
            {
                reqStream.Write(bs, 0, bs.Length);
                reqStream.Close();
            }

            string responseData = String.Empty;
            using (HttpWebResponse response = (HttpWebResponse)request.GetResponse())
            {
                using (Stream stream = response.GetResponseStream())
                {
                    byte[] bytes = new byte[response.ContentLength];
                    stream.Read(bytes, 0, bytes.Length);
                    responseData = Convert.ToBase64String(bytes);
                    responseData = "data:audio/mp3;base64," + responseData;
                    responseData = "<audio controls=\"controls\" autoplay=\"autoplay\"><source src=\"" + responseData + "\" /></audio>";
                    myAudio.InnerHtml = responseData;
                }
            }
        }

        protected void Button1_Click(object sender, EventArgs e)
        {

        }
    }
}