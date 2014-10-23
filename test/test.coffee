should = require('chai').should()
flatfile = require('../index.coffee')
async = require 'async'

describe '#create', () ->

	it 'should detect not-existant file', (done) ->
		flatfile.create 'djfdklsdjl', (err, ff) ->
			should.exist(err)
			done()

	it 'should accept existing file', (done) ->
		flatfile.create 'resources/suonenjoki_2909_0310.csv', (err, ff) ->
			should.not.exist(err)
			done()

	it 'should instantiate correct parser based on extension', (done) ->		
		async.series [
			(cb) ->
				flatfile.create 'resources/gainer.xlsx', (err, ff) ->
					should.not.exist(err)		
					ff.type.should.equal('xlsx')
					cb()
			(cb) ->
				flatfile.create 'resources/suonenjoki_2909_0310.csv', (err, ff) ->
					should.not.exist(err)		
					ff.type.should.equal('csv')
					cb()

		], done


	it 'can read XLS', (done) ->
		done()

	it 'can read XLSX', (done) ->
		done()

describe 'CSV', () ->
	
	it 'should read CSV', (done) ->
		flatfile.create 'resources/suonenjoki_2909_0310.csv', (err, ff) ->
			should.exist(ff)
			ff.type.should.equal('csv')
			ff.read (err, rows) ->
				should.exist(rows)
				rows.length.should.equal(4836)				
				done()

	it 'should stream CSV', (done) ->
		flatfile.create 'resources/suonenjoki_2909_0310.csv', (err, ff) ->
			should.exist(ff)
			ff.type.should.equal('csv')
			cnt = 0

			ff.on 'row', (row) -> cnt++

			ff.on 'end', () ->
				cnt.should.equal(4836)
				done()

			ff.stream()

	describe 'CSV options', () ->

		it 'charset can be defined', (done) ->
			flatfile.create 'resources/suonenjoki_2909_0310.csv', { charset: 'mac-roman' }, (err, ff) ->
				should.not.exist(err)
				ff.type.should.equal('csv')
				ff.charset.should.equal('mac-roman')
				
				ff.read (err, rows) ->
					should.not.exist(err)
					should.exist(rows)
					rows.length.should.equal(4836)
					rows[0]['Soittoyritys'].should.exist
					rows[0]['Soittoyritys'].should.equal('Kyllä')
					
					done()

		it 'delimiter can be manually defined', (done) ->		
			flatfile.create 'resources/cheerlead201410a.txt', { delimiter: '\t' }, (err, ff) ->
				should.not.exist(err)
				ff.type.should.equal('csv')
				ff.read (err, rows) ->
					done()

		it 'columns can be manually defined', (done) ->	
			cols = "Advertiser	Campaign	LeadId	Timestamp	Phone	email	Firstname	Lastname	gender	Birthyear	Zip	City	Address	Answers".split(/\t/)
			flatfile.create 'resources/cheerlead201410a.txt', { delimiter: '\t', columns: cols }, (err, ff) ->
				should.not.exist(err)				
				ff.charset.should.equal('utf-8')			
				ff.read (err, rows) ->
					should.exist(rows)					
					should.exist(rows[0][col]) for col in cols # check that all columns exist in record
					done()
				
describe 'XLSX', () ->
	it 'should read XLSX', (done) ->
		flatfile.create 'resources/gainer.xlsx', (err, ff) ->
			should.exist(ff)
			ff.type.should.equal('xlsx')
			ff.read (err, rows) ->
				should.exist(rows)
				rows.length.should.equal(18608)							
				should.exist(rows[0]['Viimeisin soitto'])
				done()

	it 'should stream XLSX', (done) ->
		flatfile.create 'resources/gainer.xlsx', (err, ff) ->
			should.exist(ff)
			ff.type.should.equal('xlsx')
			cnt = 0

			ff.on 'row', (row) -> cnt++

			ff.on 'end', () ->
				cnt.should.equal(18608)
				done()

			ff.stream()

	it 'should read XLSX with extra lines before actual data (#1)', (done) ->
		flatfile.create 'resources/Muutto alle 6kk.xlsx', { range: 'auto' }, (err, ff) ->
			should.exist(ff)
			should.exist(ff.props)
			ff.type.should.equal('xlsx')
			ff.read (err, rows) ->
				should.exist(rows)
				rows.length.should.equal(1500)				
				should.exist(rows[0]['NIMI'])
				done()

	it 'should read XLSX with extra lines before actual data (#2) - ignoring conditional override of header', (done) ->
		opts = { range: 'auto' }
		opts.header = (rows) ->
			return ['NIMI', 'POSTINUMERO', 'POSTITOIMIPAIKKA', 'PUHELINNUMERO'] unless rows?[0]?['NIMI']
			null

		flatfile.create 'resources/Muutto alle 6kk.xlsx', opts, (err, ff) ->
			should.exist(ff)
			should.exist(ff.props)
			ff.type.should.equal('xlsx')
			ff.read (err, rows) ->
				should.exist(rows)				
				rows.length.should.equal(1500)				
				should.exist(rows[0]['NIMI'])
				done()			

	it 'conditionally and manually assign header (#1)', (done) ->
		opts = { range: 'auto' }
		opts.header = (rows) ->
			return ['NIMI', 'POSTINUMERO', 'POSTITOIMIPAIKKA', 'PUHELINNUMERO'] unless rows?[0]?['NIMI']
			null
			
		flatfile.create 'resources/Vaasa.xlsx', opts, (err, ff) ->			
			should.exist(ff)
			should.exist(ff.props)
			ff.type.should.equal('xlsx')
			ff.read (err, rows) ->
				should.exist(rows)
				rows.length.should.equal(1500)
				should.exist(rows[0]['NIMI'])
				done()				

	it 'conditionally and manually assign header (#2)', (done) ->
		opts = { }
		opts.header = (rows) ->
			return ['NIMI', 'POSTINUMERO', 'POSTITOIMIPAIKKA', 'PUHELINNUMERO'] unless rows?[0]?['NIMI']
			null

		flatfile.create 'resources/Nurmijärvi_Telecenter.xlsx', opts, (err, ff) ->
			should.exist(ff)
			should.exist(ff.props)
			ff.type.should.equal('xlsx')
			ff.read (err, rows) ->
				should.exist(rows)				
				rows.length.should.equal(1649)
				should.exist(rows[0]['NIMI'])
				done()	

describe 'XLS', () ->
	it 'should read XLS', (done) ->
		flatfile.create 'resources/Raportti 29.9.-3.10.2014.xls', (err, ff) ->
			should.not.exist(err)
			should.exist(ff)
			ff.type.should.equal('xls')
			ff.read (err, rows) ->				
				should.exist(rows)
				rows.length.should.equal(4836)				
				should.exist(rows[0]['Aika'])
				done()		

	it 'should stream XLS', (done) ->
		flatfile.create 'resources/Raportti 29.9.-3.10.2014.xls', (err, ff) ->
			should.exist(ff)
			ff.type.should.equal('xls')
			cnt = 0

			ff.on 'row', (row) -> cnt++

			ff.on 'end', () ->
				cnt.should.equal(4836)
				done()

			ff.stream()							
			