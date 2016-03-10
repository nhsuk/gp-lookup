"use strict";

var Application = React.createClass({
  displayName: "Application",

  getInitialState: function getInitialState() {
    return {
      searchText: this.props.initialSearchText,
      results: this.props.initialResults,
      maxResults: this.props.initialMaxResults
    };
  },

  render: function render() {
    return React.createElement(
      "div",
      null,
      React.createElement(SearchForm, { searchText: this.state.searchText,
        handleSearchTextChange: this.handleSearchTextChange }),
      this.resultsList()
    );
  },

  resultsList: function resultsList() {
    if (this.state.results) {
      return React.createElement(ResultsList, { practices: this.state.results,
        pageSize: 20,
        loadMoreResults: this.loadMoreResults,
        loadMoreHref: this.loadMoreHref() });
    }
  },

  handleSearchTextChange: function handleSearchTextChange(newSearchText) {
    this.updateResults(newSearchText, 20);
  },

  loadMoreResults: function loadMoreResults() {
    this.updateResults(this.state.searchText, this.state.maxResults + 20);
  },

  loadMoreHref: function loadMoreHref() {
    // TODO handle this in a less hacky way:
    // it'll give a false positive when the total number of results is
    // coincidentally the same as the max number of results.
    if (this.state.maxResults === this.state.results.length) {
      var searchText = this.state.searchText.replace(" ", "+", "g"),
          maxResults = this.state.maxResults + 20;

      return "?search=" + searchText + "&max=" + maxResults + "#result-" + this.state.maxResults;
    }
  },

  updateResults: function updateResults(searchText, maxResults) {
    this.setState({
      searchText: searchText,
      maxResults: maxResults
    });

    if (searchText.length > 0) {
      search(searchText, maxResults).then((function (practices) {
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

    return React.createElement(
      "form",
      { name: "", id: "", action: "", method: "get", className: "gp-finder-search" },
      React.createElement(
        "div",
        { className: "block-container" },
        React.createElement(
          "h1",
          null,
          React.createElement(
            "label",
            { htmlFor: "search" },
            "Find your GP practice"
          )
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
    return React.createElement(
      "div",
      { className: "block-container" },
      this.results(),
      this.footer()
    );
  },

  results: function results() {
    if (this.props.practices.length > 0) {
      var results = this.props.practices.map(function (practice, index) {
        return React.createElement(PracticeResult, { index: index, key: practice.code, practice: practice });
      });

      return React.createElement(
        "div",
        { className: "gp-finder-results", "aria-live": "polite" },
        results
      );
    }
  },

  footer: function footer() {
    return React.createElement(ResultsFooter, { numberOfResults: this.props.practices.length,
      loadMoreResults: this.props.loadMoreResults,
      loadMoreHref: this.props.loadMoreHref });
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
        " Dr. ",
        React.createElement("span", { dangerouslySetInnerHTML: this.highlightText(practitioner.value, practitioner.matches) })
      );
    }).bind(this)),
        href = "/practice/" + this.props.practice.code,
        id = "result-" + this.props.index;

    if (this.props.practice.score.distance) {
      var distance = React.createElement(
        "p",
        { className: "distance" },
        this.props.practice.score.distance,
        " miles away"
      );
    }

    return React.createElement(
      "a",
      { href: href, className: "result", id: id },
      React.createElement("h2", { dangerouslySetInnerHTML: this.highlightText(this.props.practice.name.value, this.props.practice.name.matches) }),
      React.createElement("p", { className: "address", dangerouslySetInnerHTML: this.highlightText(this.props.practice.address.value, this.props.practice.address.matches) }),
      distance,
      practitioners
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

var ResultsFooter = React.createClass({
  displayName: "ResultsFooter",

  render: function render() {
    if (this.props.numberOfResults === 0) {
      return React.createElement(NoResults, null);
    } else if (this.props.loadMoreHref) {
      return React.createElement(EndOfPage, { loadMoreHref: this.props.loadMoreHref,
        loadMoreResults: this.props.loadMoreResults });
    } else {
      return React.createElement(EndOfResults, null);
    }
  }
});

var EndOfPage = React.createClass({
  displayName: "EndOfPage",

  render: function render() {
    return React.createElement(
      "div",
      { className: "gp-finder-foot" },
      React.createElement(
        "p",
        null,
        React.createElement(
          "a",
          { href: this.props.loadMoreHref, onClick: this.onClick },
          "Show more GP practices."
        )
      ),
      React.createElement(
        "p",
        null,
        "Or try searching again. You can search using:"
      ),
      React.createElement(
        "ul",
        null,
        React.createElement(
          "li",
          null,
          "practice name"
        ),
        React.createElement(
          "li",
          null,
          "practice address"
        ),
        React.createElement(
          "li",
          null,
          "postcode"
        ),
        React.createElement(
          "li",
          null,
          "doctor’s name"
        )
      ),
      React.createElement(
        "p",
        null,
        React.createElement(
          "a",
          { href: "#search" },
          "Search again"
        )
      )
    );
  },

  onClick: function onClick(event) {
    event.preventDefault();
    event.stopPropagation();

    this.props.loadMoreResults();

    return false;
  }
});

var EndOfResults = React.createClass({
  displayName: "EndOfResults",

  render: function render() {
    return React.createElement(
      "div",
      { className: "gp-finder-foot" },
      React.createElement(
        "p",
        null,
        "You can search using:"
      ),
      React.createElement(
        "ul",
        null,
        React.createElement(
          "li",
          null,
          "practice name"
        ),
        React.createElement(
          "li",
          null,
          "practice address"
        ),
        React.createElement(
          "li",
          null,
          "postcode"
        ),
        React.createElement(
          "li",
          null,
          "doctor’s name"
        )
      ),
      React.createElement(
        "p",
        null,
        React.createElement(
          "a",
          { href: "#search" },
          "Search again"
        )
      )
    );
  }
});

var NoResults = React.createClass({
  displayName: "NoResults",

  render: function render() {
    return React.createElement(
      "div",
      { className: "gp-finder-no-results" },
      React.createElement(
        "p",
        null,
        "Sorry, no practices have been found. ",
        React.createElement(
          "a",
          { href: "#search" },
          "Try searching again."
        )
      ),
      React.createElement(
        "p",
        null,
        "You can search using:"
      ),
      React.createElement(
        "ul",
        null,
        React.createElement(
          "li",
          null,
          "practice name"
        ),
        React.createElement(
          "li",
          null,
          "practice address"
        ),
        React.createElement(
          "li",
          null,
          "postcode"
        ),
        React.createElement(
          "li",
          null,
          "doctor’s name"
        )
      )
    );
  }
});
