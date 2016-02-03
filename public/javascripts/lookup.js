"use strict";

$("[data-react-class]").each(function() {
  var componentName = this.getAttribute("data-react-class"),
      constructor = window[componentName],
      propsJson = this.getAttribute("data-react-props"),
      props = propsJson && JSON.parse(propsJson);

  ReactDOM.render(
    React.createElement(
      constructor,
      props
    ),
    this
  );
});

var currentAjaxRequest = null;

function search(text) {

  if(null !== currentAjaxRequest) {
    currentAjaxRequest.abort();
  }

  currentAjaxRequest = $.get('/practices', {search: text});
  return currentAjaxRequest;
}
