"use strict";

function attachReactComponents() {
  var nodes = document.querySelectorAll("[data-react-class]"),
      index;

  for (index = 0; index < nodes.length; ++index) {
    var node = nodes[index],
        componentName = node.getAttribute("data-react-class"),
        constructor = window[componentName],
        propsJson = node.getAttribute("data-react-props"),
        props = propsJson && JSON.parse(propsJson);

    ReactDOM.render(
      React.createElement(
        constructor,
        props
      ),
      node
    );
  }
}

attachReactComponents();

var currentAjaxRequest = null;

function search(text, maxResults) {
  if(null !== currentAjaxRequest) {
    currentAjaxRequest.abort();
  }

  currentAjaxRequest = $.get('/practices', {search: text, max: maxResults});
  return currentAjaxRequest;
}
