var hideElements=["footer","header"];
for (var index in hideElements){
    document.getElementsByClassName(hideElements[index])[0].style.display="none";
}

var xpaths=["/html/body/div[1]/p"];

for (var indexPath in xpaths){
    var yinshenNode =document.evaluate(xpaths[indexPath], document).iterateNext();
    yinshenNode.style.display="none";
}
