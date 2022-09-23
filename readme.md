# n8n Embed Proof of Concept

We have two applications working inside its own docker container. 
Main application with login form and n8n. 
Main app has iframe with embedded n8n application. 

The idea behind this concept is that user management handled by main application and n8n always show workspace of logged in user. 


## Log in

To log in we use n8n internal API `/rest/login` endpoint:

```js
fetch('http://localhost:8080/n8n/rest/login', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json'
  },
  body: JSON.stringify({"email":login,"password":password})
})
```

This `/rest/login` endpoint responds with set-cookie. 


## CORS restrictions and solution

If you use two different web applications, each working on it's own domain, there could be a problem with CORS. When you try lo call n8n `/rest/login` from application, running on different origin (protocol + domain + port), you will probably get `Access to XMLHttpRequest at 'http://localhost:5678/rest/login' from origin 'http://localhost:3000' has been blocked by CORS policy`. You can handle it by setting `Access-Control-Allow-Origin` header in n8n response. But n8n doesn't have CORS configuration feature. Another approach is to set up for these two applications single entry point - a reverse proxy. It this PoC we use nginx for such purpose. 

Important part of nginx config:

```
  location /n8n/ {
    proxy_pass http://n8n:5678/;
  }

  location / {
    proxy_pass http://app:3000/;
  }
```

Nginx pass requests, starting with /n8n/, to n8n docker app exposed at http://n8n:5678/, and all other requets to main application exposed at http://app:3000/. And if one application sets cookie, at the browser cookies will be set up for the http://localhost:8080 origin, which shared by both aspplications due to Nginx.


## Usage PoC

```bash
make build  # build docker image for main application
make up     # run all containers
make local  # to run main application locally
```

Go to http://localhost:8080.

Refer to `Makefile` and `app/package.json` for all features.

If you want to create users, create `.env` file in project root and setup `N8N_SMTP_*` variables.