var hideElements=new Array("footer","breadcrumbs","toptool","header");
for (var index in hideElements){
    document.getElementById(hideElements[index]).style.display="none";
}

var xpaths=["//*[@id='main']/form/div/table/tbody/tr[6]", "//*[@id='main']/form/div/table/tbody/tr[7]",
                     "//*[@id='main']/form/div/table/tbody/tr[2]/th/input[2]","//*[@id='main']/form/div/table/tbody/tr[2]/td/a",
                     "//*[@id='main']/form/div/table/tbody/tr[3]/td/a","//*[@id='main']/form/div/table/tbody/tr[4]/td/font",
                     "//*[@id='main']/form/div/table/tbody/tr[5]/td/span",

                     "//*[@id='main']/form/div/table/tbody/tr[2]/th",
                     "//*[@id='main']/form/div/table/tbody/tr[3]/th","//*[@id='main']/form/div/table/tbody/tr[4]/th",
                     "//*[@id='main']/form/div/table/tbody/tr[5]/th","//*[@id='main']/form/div/table/tbody/tr[8]/td[1]",
                     "//*[@id='main']/form/div/table/tbody/tr[1]/th[1]"];

for (var indexPath in xpaths){
    var yinshenNode =document.evaluate(xpaths[indexPath], document).iterateNext();
    yinshenNode.style.display="none";
}

var enmailTextNode =document.evaluate("//*[@id='main']/form/div/table/tbody/tr[2]/th", document).iterateNext();
enmailTextNode.innerHTML= "<input type=\"radio\" name=\"lgt\" value=\"0\" checked /> 用户名";

var nameNode =document.evaluate("//*[@id='main']/form/div/table/tbody/tr[2]/td/input", document).iterateNext();
nameNode.setAttribute("placeholder","用户名");

var pwdNode =document.evaluate("//*[@id='main']/form/div/table/tbody/tr[3]/td/input", document).iterateNext();
pwdNode.setAttribute("placeholder","密码");


var answerNode =document.evaluate("//*[@id='main']/form/div/table/tbody/tr[5]/td/input", document).iterateNext();
answerNode.setAttribute("placeholder","安全问题答案");


var adNode =document.evaluate("//*[@id='wrapA']/center", document).iterateNext();
adNode.innerHTML = "";
