"use strict";

var AuthenticationState = {
  WAITING: 1,
  AUTHENTICATED: 2,
  UNAUTHENTICATED: 3
};

var Application = React.createClass({
  getInitialState: function() {
    return {
      searchText: "Devonshire",
      results: [
          { /* match on name and address */
            code: "H81070",
            name: {
              value: "Devonshire Green Medical Centre",
              matches: [
                [0, 9],
              ],
            },
            address: {
              value: "Devonshire Street, Sheffield, S3 7SF",
              matches: [
                [0, 9],
              ],
            },
            practitioners: [],
            score: {
              name: 10,
              address: 10,
              practitioners: 0,
            }
          },
          { /* match on practitioner */
            code: "Y81070",
            name: {
              value: "Clover Group Practice",
              matches: [],
            },
            address: {
              value: "Jordanthorpe Health Centre, 1 Dyche Close, Sheffield, S8 8DJ",
              matches: [],
            },
            practitioners: [
              {
                value: "JE Devonshire",
                matches: [
                  [3, 12]
                ],
              },
            ],
            score: {
              name: 0,
              address: 0,
              practitioners: 6,
            }
          },
          { /* match on practice name */
            code: "H12344",
            name: {
              value: "The Devonshire Lodge Practice",
              matches: [
                [4, 13],
              ],
            },
            address: {
              value: "2 Abbotsbury Gardens, Eastcote, Middlesex, HA5 1TG",
              matches: [],
            },
            practitioners: [],
            score: {
              name: 7,
              address: 0,
              practitioners: 0,
            }
          },
          { /* match on address only */
            code: "H812370",
            name: {
              value: "The Street Lane Practice",
              matches: [],
            },
            address: {
              value: "12 Devonshire Avenue, Southsea, Portsmouth, Hampshire, PO4 9EH",
              matches: [
                [3, 12],
              ],
            },
            practitioners: [],
            score: {
              name: 0,
              address: 8,
              practitioners: 0,
            }
          }
      ]
    };
  },

  render: function() {
    var numberOfResults = this.state.results !== null ? this.state.results.length : null;

    return (
      <div>
        <SearchForm searchText={this.state.searchText}
                    numberOfResults={numberOfResults} />
        <ResultsList practices={this.state.results} />
      </div>
    );
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
        <span class="hint">Practice name, address, GP name, postcode, etc.</span>
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
            <input type="text" name="search" id="search" className="form-control" defaultValue={this.props.searchText} />
            <button type="submit" className="button">Search</button>
          </div>
        </div>
      </form>
    );
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

        <div className="gp-finder-results">

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
        <p key={index} className="person">
          <img src="/images/person-placeholder.svg" width="45" height="45" alt="" />
          <span dangerouslySetInnerHTML={this.highlightText(practitioner.value, practitioner.matches)} />
        </p>
      );
    }.bind(this));

    return (
      <a href="#" className="result">
        <h2 dangerouslySetInnerHTML={this.highlightText(this.props.practice.name.value, this.props.practice.name.matches)} />
        <p className="address" dangerouslySetInnerHTML={this.highlightText(this.props.practice.address.value, this.props.practice.address.matches)} />
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

    for(var i = 0 ; i < text.length ; i++) {
      if(startIndices[i]){
        output += '<strong>';
      }
      if(endIndices[i - 1]){
        output += '</strong>';
      }

      output += text[i];
    }
    return {__html: output};
  }

});

ReactDOM.render(
  <Application />,
  document.getElementById("application-container")
);
