var path = require('path');
var CopyWebpackPlugin = require('copy-webpack-plugin');

module.exports = {
  entry: './js/app.js',
  output: {
	filename: 'js/wwm.bundle.js',
	path: path.resolve(__dirname, '../priv/static'),
	sourceMapFilename: "wwm.bundle.map",
  },
  module: {
		rules: [
			{
				test: /\.js$/,
				exclude: /(node_modules|bower_components)/,
				use: {
					loader: 'babel-loader',
					options: {
						presets: ['env']
					}
				}
			}
		]
	},
	plugins: [
        new CopyWebpackPlugin([
            { from: 'static' }
        ])
    ]
};
