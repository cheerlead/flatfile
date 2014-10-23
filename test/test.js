// Generated by CoffeeScript 1.7.1
var async, flatfile, should;

should = require('chai').should();

flatfile = require('../index.coffee');

async = require('async');

describe('#create', function() {
  it('should detect not-existant file', function(done) {
    return flatfile.create('djfdklsdjl', function(err, ff) {
      should.exist(err);
      return done();
    });
  });
  it('should accept existing file', function(done) {
    return flatfile.create('resources/suonenjoki_2909_0310.csv', function(err, ff) {
      should.not.exist(err);
      return done();
    });
  });
  it('should instantiate correct parser based on extension', function(done) {
    return async.series([
      function(cb) {
        return flatfile.create('resources/gainer.xlsx', function(err, ff) {
          should.not.exist(err);
          ff.type.should.equal('xlsx');
          return cb();
        });
      }, function(cb) {
        return flatfile.create('resources/suonenjoki_2909_0310.csv', function(err, ff) {
          should.not.exist(err);
          ff.type.should.equal('csv');
          return cb();
        });
      }
    ], done);
  });
  it('can read XLS', function(done) {
    return done();
  });
  return it('can read XLSX', function(done) {
    return done();
  });
});

describe('CSV', function() {
  it('should read CSV', function(done) {
    return flatfile.create('resources/suonenjoki_2909_0310.csv', function(err, ff) {
      should.exist(ff);
      ff.type.should.equal('csv');
      return ff.read(function(err, rows) {
        should.exist(rows);
        rows.length.should.equal(4836);
        return done();
      });
    });
  });
  it('should stream CSV', function(done) {
    return flatfile.create('resources/suonenjoki_2909_0310.csv', function(err, ff) {
      var cnt;
      should.exist(ff);
      ff.type.should.equal('csv');
      cnt = 0;
      ff.on('row', function(row) {
        return cnt++;
      });
      ff.on('end', function() {
        cnt.should.equal(4836);
        return done();
      });
      return ff.stream();
    });
  });
  return describe('CSV options', function() {
    it('charset can be defined', function(done) {
      return flatfile.create('resources/suonenjoki_2909_0310.csv', {
        charset: 'mac-roman'
      }, function(err, ff) {
        should.not.exist(err);
        ff.type.should.equal('csv');
        ff.charset.should.equal('mac-roman');
        return ff.read(function(err, rows) {
          should.not.exist(err);
          should.exist(rows);
          rows.length.should.equal(4836);
          rows[0]['Soittoyritys'].should.exist;
          rows[0]['Soittoyritys'].should.equal('Kyllä');
          return done();
        });
      });
    });
    it('delimiter can be manually defined', function(done) {
      return flatfile.create('resources/cheerlead201410a.txt', {
        delimiter: '\t'
      }, function(err, ff) {
        should.not.exist(err);
        ff.type.should.equal('csv');
        return ff.read(function(err, rows) {
          return done();
        });
      });
    });
    return it('columns can be manually defined', function(done) {
      var cols;
      cols = "Advertiser	Campaign	LeadId	Timestamp	Phone	email	Firstname	Lastname	gender	Birthyear	Zip	City	Address	Answers".split(/\t/);
      return flatfile.create('resources/cheerlead201410a.txt', {
        delimiter: '\t',
        columns: cols
      }, function(err, ff) {
        should.not.exist(err);
        ff.charset.should.equal('utf-8');
        return ff.read(function(err, rows) {
          var col, _i, _len;
          should.exist(rows);
          for (_i = 0, _len = cols.length; _i < _len; _i++) {
            col = cols[_i];
            should.exist(rows[0][col]);
          }
          return done();
        });
      });
    });
  });
});

describe('XLSX', function() {
  it('should read XLSX', function(done) {
    return flatfile.create('resources/gainer.xlsx', function(err, ff) {
      should.exist(ff);
      ff.type.should.equal('xlsx');
      return ff.read(function(err, rows) {
        should.exist(rows);
        rows.length.should.equal(18608);
        should.exist(rows[0]['Viimeisin soitto']);
        return done();
      });
    });
  });
  it('should stream XLSX', function(done) {
    return flatfile.create('resources/gainer.xlsx', function(err, ff) {
      var cnt;
      should.exist(ff);
      ff.type.should.equal('xlsx');
      cnt = 0;
      ff.on('row', function(row) {
        return cnt++;
      });
      ff.on('end', function() {
        cnt.should.equal(18608);
        return done();
      });
      return ff.stream();
    });
  });
  it('should read XLSX with extra lines before actual data (#1)', function(done) {
    return flatfile.create('resources/Muutto alle 6kk.xlsx', {
      range: 'auto'
    }, function(err, ff) {
      should.exist(ff);
      should.exist(ff.props);
      ff.type.should.equal('xlsx');
      return ff.read(function(err, rows) {
        should.exist(rows);
        rows.length.should.equal(1500);
        should.exist(rows[0]['NIMI']);
        return done();
      });
    });
  });
  it('should read XLSX with extra lines before actual data (#2) - ignoring conditional override of header', function(done) {
    var opts;
    opts = {
      range: 'auto'
    };
    opts.header = function(rows) {
      var _ref;
      if (!(rows != null ? (_ref = rows[0]) != null ? _ref['NIMI'] : void 0 : void 0)) {
        return ['NIMI', 'POSTINUMERO', 'POSTITOIMIPAIKKA', 'PUHELINNUMERO'];
      }
      return null;
    };
    return flatfile.create('resources/Muutto alle 6kk.xlsx', opts, function(err, ff) {
      should.exist(ff);
      should.exist(ff.props);
      ff.type.should.equal('xlsx');
      return ff.read(function(err, rows) {
        should.exist(rows);
        rows.length.should.equal(1500);
        should.exist(rows[0]['NIMI']);
        return done();
      });
    });
  });
  it('conditionally and manually assign header (#1)', function(done) {
    var opts;
    opts = {
      range: 'auto'
    };
    opts.header = function(rows) {
      var _ref;
      if (!(rows != null ? (_ref = rows[0]) != null ? _ref['NIMI'] : void 0 : void 0)) {
        return ['NIMI', 'POSTINUMERO', 'POSTITOIMIPAIKKA', 'PUHELINNUMERO'];
      }
      return null;
    };
    return flatfile.create('resources/Vaasa.xlsx', opts, function(err, ff) {
      should.exist(ff);
      should.exist(ff.props);
      ff.type.should.equal('xlsx');
      return ff.read(function(err, rows) {
        should.exist(rows);
        rows.length.should.equal(1500);
        should.exist(rows[0]['NIMI']);
        return done();
      });
    });
  });
  return it('conditionally and manually assign header (#2)', function(done) {
    var opts;
    opts = {};
    opts.header = function(rows) {
      var _ref;
      if (!(rows != null ? (_ref = rows[0]) != null ? _ref['NIMI'] : void 0 : void 0)) {
        return ['NIMI', 'POSTINUMERO', 'POSTITOIMIPAIKKA', 'PUHELINNUMERO'];
      }
      return null;
    };
    return flatfile.create('resources/Nurmijärvi_Telecenter.xlsx', opts, function(err, ff) {
      should.exist(ff);
      should.exist(ff.props);
      ff.type.should.equal('xlsx');
      return ff.read(function(err, rows) {
        should.exist(rows);
        rows.length.should.equal(1649);
        should.exist(rows[0]['NIMI']);
        return done();
      });
    });
  });
});

describe('XLS', function() {
  it('should read XLS', function(done) {
    return flatfile.create('resources/Raportti 29.9.-3.10.2014.xls', function(err, ff) {
      should.not.exist(err);
      should.exist(ff);
      ff.type.should.equal('xls');
      return ff.read(function(err, rows) {
        should.exist(rows);
        rows.length.should.equal(4836);
        should.exist(rows[0]['Aika']);
        return done();
      });
    });
  });
  return it('should stream XLS', function(done) {
    return flatfile.create('resources/Raportti 29.9.-3.10.2014.xls', function(err, ff) {
      var cnt;
      should.exist(ff);
      ff.type.should.equal('xls');
      cnt = 0;
      ff.on('row', function(row) {
        return cnt++;
      });
      ff.on('end', function() {
        cnt.should.equal(4836);
        return done();
      });
      return ff.stream();
    });
  });
});