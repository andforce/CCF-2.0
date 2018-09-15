let list = document.getElementById("list");

list.addEventListener("touchstart", function (event) {
    let el = event.target;
    while (el && !el.getAttribute('data-id')) {
        el = el.parentNode;
    }

    if (el){
        el.style.backgroundColor = '#F1F1F1';
    }
});

list.addEventListener("touchend", function (event) {
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
            //location.href = el.getAttribute('data-id');
            webkit.messageHandlers.onPostMessageClicked.postMessage(el.getAttribute('data-id'));
        }
    }
});