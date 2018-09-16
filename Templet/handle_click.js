let list = document.getElementById("list");

var touched = false;

list.addEventListener("touchstart", function (event) {
    touched = true;

    let el = event.target;
    while (el && !el.getAttribute('data-id')) {
        el = el.parentNode;
    }

    if (el){

        // el.style.backgroundColor = '#F1F1F1';

        setTimeout(changeBgColor,100);

        function changeBgColor() {
            if (touched) {
                el.style.backgroundColor = '#F1F1F1';
            }
        }
    }
});

list.addEventListener("touchend", function (event) {
    touched = false;

    let el = event.target;
    while (el && !el.getAttribute('data-id')) {
        el = el.parentNode;
    }
    if (el){
        el.style.backgroundColor = '';
    }
});

list.addEventListener("touchmove", function (event) {
    touched = false;

    let el = event.target;
    while (el && !el.getAttribute('data-id')) {
        el = el.parentNode;
    }
    if (el){
        el.style.backgroundColor = '';
    }
});


list.addEventListener("touchcancel", function (event) {
    let el = event.target;
    while (el && !el.getAttribute('data-id')) {
        el = el.parentNode;
    }
    if (el){
        el.style.backgroundColor = '';
    }
});

//http://stackoverflow.com/questions/4712310/javascript-how-to-detect-if-a-word-is-highlighted
function getSelectedText() {
    var text = "";
    if (typeof window.getSelection !== "undefined") {
        text = window.getSelection().toString();
    } else if (typeof document.selection !== "undefined" && document.selection.type === "Text") {
        text = document.selection.createRange().text;
    }
    return text;
}

list.addEventListener("click", function (event) {
    let el = event.target;

    webkit.messageHandlers.onDebug.postMessage(el.nodeName +"-" + el.nodeType);

    if (el.nodeName === 'A') {
        webkit.messageHandlers.onLinkClicked.postMessage(el.href);
        return;
    }

    if (el.nodeName === 'IMG') {
        // 点击头像
        if (el.parentNode.nodeName === 'A' && el.parentNode.parentNode.nodeName === 'SPAN' && el.parentNode.parentNode.className === 'avatar') {
            webkit.messageHandlers.onAvatarClicked.postMessage(el.parentNode.href);
            return;
        }
        // 点击图片
        // 1。放大观看
        if (el.parentNode.nodeName !== 'A') {
            webkit.messageHandlers.onImageClicked.postMessage(el.src);
            return
        }
        // 2。链接跳转
        if (el.parentNode.nodeName === 'A') {
            webkit.messageHandlers.onLinkClicked.postMessage(el.parentNode.href);
        }
    } else {
        while (el && !el.getAttribute('data-id')) {
            el = el.parentNode;
            if (el.nodeName === 'A') {
                return;
            }
        }
        if (el) {
            el.style.backgroundColor = '#F1F1F1';

            setTimeout(changeBgColorClick,150);

            function changeBgColorClick() {
                el.style.backgroundColor = '';
            }
            //location.href = el.getAttribute('data-id');
            webkit.messageHandlers.onPostMessageClicked.postMessage(el.getAttribute('data-id'));
        }
    }
});