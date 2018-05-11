#!/usr/bin/env node

/**
 * This script accepts a markdown file from stdin, transforms it, then outputs an HTML version
 * on stdout. (Optionally as a data URI with the `--data-uri` option.)
 */

const remark = require('remark');
const select = require('unist-util-select');
const html = require('remark-html');

function output(html) {
	if (process.argv.includes('--data-uri')) {
		process.stdout.write(`data:text/html;base64,`);
		process.stdout.write(new Buffer(html, 'utf8').toString('base64'));
	} else {
		process.stdout.write(html);
	}
}

function transform(input) {
	remark()
		.use(require('.'))
		.use(html)
		.process(inputFile.replace(/\t/g, '  '), function(err, file) {
			if (err) throw err;
			output(file.toString())
		});
}

let inputFile = '';
process.stdin.setEncoding('utf8');
process.stdin.on('data', chunk => (inputFile += chunk));
process.stdin.on('end', () => transform(inputFile));
process.stdin.resume();
