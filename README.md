
## Mentions:

I created the default phx project, but I haven't used all the dependencies, I could make it lighter(install it without ecto and just add ecto without the db part since I don't persist anything)

Since this a practice/test project I made some assumtions about how structure my project and:
* decided to create the Job and Task module
* decided to have the bash script as an optional field to the same request

## Testing the API endpoint
start the app
`$ mix phx.server`

### Curl request with the example from the requirements
`$ curl --location --request POST 'http://localhost:4000/job/sort'  --header 'Content-Type: application/json'  --data-raw '{  "tasks": [  {  "name": "task-1",  "command": "touch /tmp/file1"  },  {  "name": "task-2",  "command":"cat /tmp/file1",  "requires":[  "task-3"  ]  },  {  "name": "task-3",  "command": "echo '\''Hello World!'\'' > /tmp/file1",  "requires":[  "task-1"  ]  },  {  "name": "task-4",  "command": "rm /tmp/file1",  "requires":[  "task-2",  "task-3"  ]  }  ]  }'`


### Curl request with the example, but including the "return_bash_script" option
`$ curl --location --request POST 'http://localhost:4000/job/sort'  --header 'Content-Type: application/json'  --data-raw '{"return_bash_script": true,  "tasks": [  {  "name": "task-1",  "command": "touch /tmp/file1"  },  {  "name": "task-2",  "command":"cat /tmp/file1",  "requires":[  "task-3"  ]  },  {  "name": "task-3",  "command": "echo '\''Hello World!'\'' > /tmp/file1",  "requires":[  "task-1"  ]  },  {  "name": "task-4",  "command": "rm /tmp/file1",  "requires":[  "task-2",  "task-3"  ]  }  ]  }'`

Other useful things for the review:
* `$ git log` or `https://github.com/mihailacusteanu/job_processing/commits/master` for the commits list
* test files
  * `test/job_processing/data/job_test.exs`
  * `test/job_processing/data/task_test.exs`
  * `test/job_processing_web/controllers/job_controller_test.exs`