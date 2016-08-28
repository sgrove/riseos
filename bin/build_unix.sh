mirage configure --net=socket --http_port=3000 --https_port=3001 -t unix --show_errors=true --mailgun_api_key="${MAILGUN_API_KEY}" --error_report_emails="${ERROR_REPORT_EMAIL}"
make clean
make
mv mir-riseos ${CIRCLE_ARTIFACTS}/
