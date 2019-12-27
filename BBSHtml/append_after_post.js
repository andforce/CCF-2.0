var node = document.createElement('LI');
node.setAttribute('class', 'post-message');
node.setAttribute('data-id', 'postid://%@?postid=%@&postuser=%@&postlouceng=%@');
node.innerHTML = "%@";
document.getElementById('list').appendChild(node);