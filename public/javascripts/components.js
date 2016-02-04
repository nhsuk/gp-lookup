"use strict";

var Application = React.createClass({
  displayName: "Application",

  getInitialState: function getInitialState() {
    return {
      searchText: this.props.initialSearchText,
      results: this.props.initialResults
    };
  },

  render: function render() {
    var numberOfResults = this.state.results !== null ? this.state.results.length : null,
        resultsList = null;

    if (numberOfResults) {
      resultsList = React.createElement(ResultsList, { practices: this.state.results });
    }
    return React.createElement(
      "div",
      null,
      React.createElement(SearchForm, { searchText: this.state.searchText,
        numberOfResults: numberOfResults,
        handleSearchTextChange: this.handleSearchTextChange }),
      resultsList
    );
  },

  handleSearchTextChange: function handleSearchTextChange(newSearchText) {
    this.setState({
      searchText: newSearchText
    });

    if (newSearchText.length >= 3) {
      search(newSearchText).then((function (practices) {
        console.log('Updating practices: ', practices);
        this.setState({
          results: practices
        });
      }).bind(this));
    } else {
      this.setState({
        results: null
      });
    }
  }
});

var SearchForm = React.createClass({
  displayName: "SearchForm",

  render: function render() {
    var hintSpan;

    if (null !== this.props.numberOfResults) {
      hintSpan = React.createElement(
        "span",
        { className: "hint" },
        this.props.numberOfResults,
        " results found for ",
        React.createElement(
          "span",
          { className: "visuallyhidden" },
          this.props.searchText
        )
      );
    } else {
      hintSpan = React.createElement(
        "span",
        { className: "hint" },
        "Search for practice name, address, GP name, postcode, etc"
      );
    }

    return React.createElement(
      "form",
      { name: "", id: "", action: "", method: "get", className: "gp-finder-search" },
      React.createElement(
        "div",
        { className: "block-container" },
        React.createElement(
          "label",
          { htmlFor: "search" },
          "Find your GP practice",
          hintSpan
        ),
        React.createElement(
          "div",
          { className: "clearfix" },
          React.createElement("input", { type: "text", name: "search", id: "search", className: "form-control",
            value: this.props.searchText,
            onChange: this.onChange }),
          React.createElement(
            "button",
            { type: "submit", className: "button" },
            "Search"
          )
        )
      )
    );
  },

  onChange: function onChange(event) {
    this.props.handleSearchTextChange(event.target.value);
  }
});

var ResultsList = React.createClass({
  displayName: "ResultsList",

  render: function render() {
    var practiceResults = this.props.practices.map(function (practice, index) {
      return React.createElement(PracticeResult, { key: practice.code,
        practice: practice });
    });

    return React.createElement(
      "div",
      { className: "block-container" },
      React.createElement(
        "div",
        { className: "gp-finder-results" },
        practiceResults
      )
    );
  }
});

var PracticeResult = React.createClass({
  displayName: "PracticeResult",

  render: function render() {
    var practitioners = this.props.practice.practitioners.map((function (practitioner, index) {
      return React.createElement(
        "p",
        { className: "person" },
        React.createElement("img", { src: "/images/person-placeholder.svg", width: "45", height: "45", alt: "" }),
        " ",
        React.createElement("span", { dangerouslySetInnerHTML: this.highlightText(practitioner.value, practitioner.matches) })
      );
    }).bind(this)),
        firstPractitioner = practitioners[0],
        href = "/book/" + this.props.practice.code;

    return React.createElement(
      "a",
      { href: href, className: "result" },
      React.createElement("h2", { dangerouslySetInnerHTML: this.highlightText(this.props.practice.name.value, this.props.practice.name.matches) }),
      React.createElement("p", { className: "address", dangerouslySetInnerHTML: this.highlightText(this.props.practice.address.value, this.props.practice.address.matches) }),
      firstPractitioner
    );
  },

  highlightText: function highlightText(text, matches) {
    var startIndices = {},
        endIndices = {},
        output = [];

    matches.forEach(function (startEndPair) {
      startIndices[startEndPair[0]] = true;
      endIndices[startEndPair[1]] = true;
    });

    for (var i = 0; i < text.length + 1; i++) {
      if (startIndices[i]) {
        output += '<strong>';
      }
      if (endIndices[i - 1]) {
        output += '</strong>';
      }
      if (!!text[i]) {
        output += text[i];
      }
    }
    return { __html: output };
  }

});
