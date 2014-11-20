
iconv = require('iconv-lite') # https://github.com/ashtuchkin/iconv-lite
parse = require 'csv-parse' # https://github.com/wdavidw/node-csv-parse
jschardet = require("jschardet") # https://github.com/aadsm/jschardet
fs = require 'fs'
async = require 'async'
xlsx = require('xlsx') # https://github.com/SheetJS/js-xlsx
xls = require 'xlsjs' #https://github.com/SheetJS/js-xls
_ = require 'underscore'

###############################################################################
# CSV Parser
#
# Parses CSV files using the csv-parse library.

csvParser = (file, opts, callback) ->
	[opts, callback] = [{}, opts] if typeof opts is 'function'

	charset = opts.charset || null
	parser = null

	async.series [
		# detect charset
		(cb) ->
			return cb() if charset?

			stream = fs.createReadStream(file, { end: 5*1024 })
			stream.on 'readable', () ->
				return if charset?
				buf = stream.read()
				charset = jschardet.detect(buf)?.encoding
				stream.close()
				cb()
	], (err) ->
		return callback(err) if err?

		csvOpts = { }
		csvOpts.columns = opts.columns || true
		csvOpts.delimiter = opts.delimiter || ';'
		csvOpts.trim = opts.trim || true
		csvOpts.skip_empty_lines = opts.skip_empty_lines || true

		p =
			type: 'csv'
			charset: charset
			events: {}

			on: (event, cb) -> this.events[event] = cb

			# start streaming
			stream: () ->
				return if parser?

				parser = parse csvOpts
				stream = fs.createReadStream(file)

				rowCallback = this.events['row']
				endCallback = this.events['end']
				errorCallback = this.events['error']

				parser.on 'readable', () ->
					row = parser.read()
					while (row?)
						rowCallback(row) if rowCallback?
						row = parser.read()

				parser.on 'finish', () ->
					process.nextTick () ->
						endCallback() if endCallback()

				parser.on 'error', (err) -> errorCallback(err) if errorCallback?

				p = stream
				p = stream.pipe(iconv.decodeStream(charset)) if charset? and charset != 'utf-8'
				p.pipe(parser)

			# read rows into array and return it
			read: (callback) ->
				return if parser?

				parser = parse csvOpts
				stream = fs.createReadStream(file)

				rows = []

				parser.on 'readable', () ->
					row = parser.read()
					while (row?)
						rows.push row
						row = parser.read()

				parser.on 'finish', () ->
					callback(null, rows)

				p = stream
				p = stream.pipe(iconv.decodeStream(charset)) if charset? and charset != 'utf-8'
				p.pipe(parser)

		callback(null, p)

###############################################################################
# Excel Parser
#
# Parses Excel files using the js-xls and js-xlsx libraries.
#
# Sheet. An integer number that specifies the requested sheet. Default 0.

excelParser = (file, opts, callback) ->
	[opts, callback] = [{}, opts] if typeof opts is 'function'

	parser = xlsx
	parser = xls if file.toLowerCase().match(/xls$/)

	sheet = null
	workbook = parser.readFile(file);

	opts = _.clone(opts)

	if opts.range == 'auto'
		# If there is an empty line along the 10 first lines, start
		# after that

		sheet = workbook.Sheets[workbook.SheetNames[opts.sheet || 0]]
		r = parser.utils.decode_range(sheet["!ref"]);

		row = 0
		while row < 10 and r.e.r > 10 #r.e.r
			val = sheet[parser.utils.encode_col(0) + parser.utils.encode_row(row);]
			if val == undefined
				opts.range = row+1
				break
			row++

		delete opts.range if opts.range == 'auto'

	if opts.header? and typeof opts.header is 'function' and not opts.range?
		# conditionally assign header
		sheet = workbook.Sheets[workbook.SheetNames[opts.sheet || 0]]
		rows = parser.utils.sheet_to_json(sheet, opts)

		header = opts.header(rows)
		delete opts.header
		opts.header = header if header?
		sheet = null

	p =
		type: if parser == xls then 'xls' else 'xlsx'
		events: {}
		on: (event, cb) -> this.events[event] = cb

		columns: opts.columns || null

		read: (callback) ->
			sheet = workbook.Sheets[workbook.SheetNames[opts.sheet || 0]] unless sheet?
			callback(null, parser.utils.sheet_to_json(sheet, opts))

		stream: () ->
			sheet = workbook.Sheets[workbook.SheetNames[opts.sheet || 0]] unless sheet?

			rowCallback = this.events['row']
			endCallback = this.events['end']
			errorCallback = this.events['error']

			for row in parser.utils.sheet_to_json(sheet, opts)
				rowCallback(row) if rowCallback?

			endCallback() if endCallback()

		props: workbook.Props

	callback(null, p)


###############################################################################
# Module exports
#

module.exports =

	create: (file, opts, callback) ->
		[opts, callback] = [{}, opts] if typeof opts is 'function'

		parser = null

		async.series [
			(cb) ->
				fs.exists file, (exists) ->
					cb(if exists then null else "file '#{file}' not found")

			(cb) ->
				parser = csvParser if file.toLowerCase().match(/(csv|txt)$/)
				parser = excelParser if file.toLowerCase().match(/(xls|xlsx)$/)
				cb()

		], (err) ->
			err = "Unknown file type: '#{file}'" unless parser?
			return callback(err) if err?
			parser(file, opts, callback)

