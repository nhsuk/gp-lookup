"use strict";

var Application = React.createClass({
  getInitialState: function() {
    return {
      searchText: this.props.initialSearchText,
      results: this.props.initialResults,
      maxResults: 20
    };
  },

  render: function() {
    var numberOfResults = null,
        resultsList = null;

    if (this.state.results !== null) {
      numberOfResults = this.state.results.length;
    }

    if (numberOfResults === 0) {
      resultsList = (<NoResults />);
    }
    else if(numberOfResults) {
      resultsList = (
        <ResultsList practices={this.state.results}
                     loadMoreResults={this.loadMoreResults}
                     loadMoreHref={this.loadMoreHref()} />
      );
    };

    return (
      <div>
        <SearchForm searchText={this.state.searchText}
                    handleSearchTextChange={this.handleSearchTextChange} />
        {resultsList}
      </div>
    );
  },

  handleSearchTextChange: function(newSearchText) {
    this.updateResults(newSearchText, 20);
  },

  loadMoreResults: function() {
    this.updateResults(this.state.searchText, this.state.maxResults + 20);
  },

  loadMoreHref: function() {
    var searchText = this.state.searchText.replace(" ", "+", "g"),
        maxResults = this.state.maxResults + 20;

    return "?search=" + searchText + "&max=" + maxResults;
  },

  updateResults: function(searchText, maxResults) {
    this.setState({
      searchText: searchText,
      maxResults: maxResults
    });

    if (searchText.length > 0) {
      search(searchText, maxResults).then(function(practices) {
        this.setState({
          results: practices
        });
      }.bind(this));
    } else {
      this.setState({
        results: null
      });
    }
  }
});

var SearchForm = React.createClass({
  render: function() {

    return (
      <form name="" id="" action="" method="get" className="gp-finder-search">
        <div className="block-container">
          <h1>
            <label htmlFor="search">
              Find your GP practice
            </label>
          </h1>
          <div className="clearfix">
            <input type="text" name="search" id="search" className="form-control"
                   value={this.props.searchText}
                   onChange={this.onChange} />
            <button type="submit" className="button">Search</button>
          </div>
        </div>
      </form>
    );
  },

  onChange: function(event) {
    this.props.handleSearchTextChange(event.target.value);
  }
});


var ResultsList = React.createClass({
  render: function() {
    var practiceResults = this.props.practices.map(function(practice, index) {
      return (<PracticeResult key={practice.code}
                              practice={practice} />);
    });

    return (
      <div className="block-container">
        <div className="gp-finder-results" aria-live="polite">
          {practiceResults}
        </div>

        <ResultsFooter loadMoreResults={this.props.loadMoreResults}
                       loadMoreHref={this.props.loadMoreHref} />
      </div>
    );
  }
});

var PracticeResult = React.createClass({
  render: function() {
    var practitioners = this.props.practice.practitioners.map(function(practitioner, index) {
          return (
            <p className="person">
              <img src="/images/person-placeholder.svg" width="45" height="45" alt="" />
              { " Dr. " }
              <span dangerouslySetInnerHTML={this.highlightText(practitioner.value, practitioner.matches)} />
            </p>
          );
        }.bind(this)),
        href = "/book/" + this.props.practice.code;

    if (this.props.practice.score.distance) {
      var distance = (
        <p className="distance">{this.props.practice.score.distance} miles away</p>
      );
    }

    return (
      <a href={href} className="result">
        <h2 dangerouslySetInnerHTML={this.highlightText(this.props.practice.name.value, this.props.practice.name.matches)} />
        <p className="address" dangerouslySetInnerHTML={this.highlightText(this.props.practice.address.value, this.props.practice.address.matches)} />
        {distance}
        {practitioners}
      </a>
    );
  },

  highlightText: function(text, matches) {
    var startIndices = {},
        endIndices = {},
        output = [];

    matches.forEach(function(startEndPair) {
      startIndices[startEndPair[0]] = true;
      endIndices[startEndPair[1]] = true;
    });

    for(var i = 0 ; i < text.length + 1 ; i++) {
      if(startIndices[i]){
        output += '<strong>';
      }
      if(endIndices[i - 1]){
        output += '</strong>';
      }
      if(!!text[i]) {
        output += text[i];
      }
    }
    return {__html: output};
  }

});


var ResultsFooter = React.createClass({
  render: function() {
    return (
      <div className="gp-finder-foot">
        <p>
          <a href={this.props.loadMoreHref} onClick={this.onClick}>Show more GP practices.</a>
        </p>
        <p>
          Or try searching again. You can search using:
        </p>
        <ul>
          <li>practice name</li>
          <li>practice address</li>
          <li>postcode</li>
          <li>doctor’s name</li>
        </ul>
        <p>
          <a href="#search">Search again</a>
        </p>
      </div>
    );
  },

  onClick: function(event) {
    event.preventDefault();
    event.stopPropagation();

    this.props.loadMoreResults();

    return false;
  }
});


var NoResults = React.createClass({
  render: function() {
    return (
      <div className="block-container">
        <div className="gp-finder-no-results">
          <p>
            Sorry, no practices have been found. <a href="#search">Try searching again.</a>
          </p>
          <p>
            You can search using:
          </p>
          <ul>
            <li>practice name</li>
            <li>practice address</li>
            <li>postcode</li>
            <li>doctor’s name</li>
          </ul>
        </div>
      </div>
    );
  }
});
