"use strict";

var Application = React.createClass({
  getInitialState: function() {
    return {
      searchText: this.props.initialSearchText,
      results: this.props.initialResults
    };
  },

  render: function() {
    var numberOfResults = this.state.results !== null ? this.state.results.length : null,
        resultsList = null;

    if(numberOfResults) {
      resultsList = (<ResultsList practices={this.state.results} />);
    }
    return (
      <div>
        <SearchForm searchText={this.state.searchText}
                    numberOfResults={numberOfResults}
                    handleSearchTextChange={this.handleSearchTextChange} />
       {resultsList}
      </div>
    );
  },

  handleSearchTextChange: function(newSearchText) {
    this.setState({
      searchText: newSearchText
    });

    if(newSearchText.length > 0) {
      search(newSearchText).then(function(practices) {
        console.log('Updating practices: ', practices);
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
    var hintSpan;

    if(null !== this.props.numberOfResults) {
      hintSpan = (
        <span className="hint">{this.props.numberOfResults} results found for <span className="visuallyhidden">{this.props.searchText}</span></span>
      );
    } else {
      hintSpan = (
        <span className="hint">Practice name, address, GP name, postcode, etc.</span>
      );
    }

    return (
      <form name="" id="" action="" method="get" className="gp-finder-search">
        <div className="block-container">
          <label htmlFor="search">
            Find your GP practice
            {hintSpan}
          </label>
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
