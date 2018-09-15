let list = document.getElementById("list");
let img_click_el = function (el) {
    let p = getPosition(el);
    location.href = 'image://' + el.src;
    webkit.messageHandlers.onImageClicked.postMessage(el.src);
};
list.addEventListener("click", function (event) {
    let el = event.target;
    if (el.nodeName === 'A') {
        return;
    } else if (el.nodeName === 'DIV' && el.className === 'img_placeholder') {
        return;
    } else if (el.nodeName === 'IMG') {
        if (el.parentNode.nodeName === 'A') {
            return;
        }
        if (el.getAttribute('data-id')) {
            location.href = el.getAttribute('data-id');
            webkit.messageHandlers.onPostMessageClicked.postMessage(location.href);
        } else {
            img_click_el(el);
        }
    } else if (el.nodeName === 'SPAN' && el.getAttribute('data-id')) {
        location.href = el.getAttribute('data-id');
        webkit.messageHandlers.onPostMessageClicked.postMessage(location.href);
    } else {
        while (el && !el.getAttribute('data-id')) {
            el = el.parentNode;
            if (el.nodeName === 'A') return;
        }
        if (el) {
            location.href = el.getAttribute('data-id');
            webkit.messageHandlers.onPostMessageClicked.postMessage(location.href);
        }
    }
});
let img_click = function (el) {
    let s = el.getAttribute('image').replace(/\\/g, '');
    let div = document.createElement('div');
    div.innerHTML = s;
    let imageNode = div.firstChild;
    el.parentNode.insertBefore(imageNode, el);
    el.parentNode.removeChild(el);
};

//http://stackoverflow.com/questions/4712310/javascript-how-to-detect-if-a-word-is-highlighted
function getSelectedText() {
    let text = "";
    if (typeof window.getSelection !== "undefined") {
        text = window.getSelection().toString();
    } else if (typeof document.selection !== "undefined" && document.selection.type === "Text") {
        text = document.selection.createRange().text;
    }
    return text;
}

function getPosition(element) {
    let xPosition = 0;
    let yPosition = 0;
    while (element) {
        xPosition += (element.offsetLeft - element.scrollLeft + element.clientLeft);
        yPosition += (element.offsetTop - element.scrollTop + element.clientTop);
        element = element.offsetParent;
    }
    return {x: xPosition, y: yPosition};
}

let images = document.getElementsByTagName('IMG');
for (let i in images) {
    if (images[i].src.indexOf("http://www.hi-pda.com/forum/uc_server/data/avatar/") === 0) {
        continue;
    }
    images[i].onerror = function () {
        this.onerror = null;
        this.src = this.src;
    }
}