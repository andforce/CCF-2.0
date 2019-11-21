var hideElements=["hd","ft","toptb"];
for (var index in hideElements){
    document.getElementById(hideElements[index]).style.display="none";
}

var hideClasses=["y","xs2","tipcol","bdshare-slide-button"];
for (index in hideClasses){
    var toHide = document.getElementsByClassName(hideClasses[index]);
    for (var i = 0; i < toHide.length; i++){
        toHide[i].style.display="none";
    }
}

document.getElementById("wp").style.width="100%";

//*[@id="nv_member"]/div[9]
var xPaths=["//*[@id=\"nv_member\"]/div[9]"];

for (var indexPath in xPaths){
    var yinshenNode =document.evaluate(xPaths[indexPath], document).iterateNext();
    yinshenNode.style.display="none";
}


xPaths=["//*[@id=\"cookietime_LypJq\"]"];

for (indexPath in xPaths){
    yinshenNode =document.evaluate(xPaths[indexPath], document).iterateNext();
    yinshenNode.checked = true;
}

xPaths = ["//*[@id=\"loginform_LypJq\"]/div/div[5]"];
for (indexPath in xPaths){
    yinshenNode =document.evaluate(xPaths[indexPath], document).iterateNext();
    yinshenNode.style.display = "none";
}