const { format, transports, createLogger } = require('winston')

const { combine, timestamp } = format
const fs = require('fs-extra')
const path = require('path')

module.exports = function(name) {
	const paperLogDir = path.resolve(__dirname, `../log/${name}`)
	fs.ensureDirSync(paperLogDir)
	const blockLogger = createLogger({
		format: combine(timestamp(), format.json()),
		transports: [
			new transports.File({
				filename: `${paperLogDir}/${name}.log`,
				json: true,
				maxsize: 5242880, // 5MB
				maxFiles: 5,
				colorize: false
			})
		]
	})
	return blockLogger
}
