# Introduction
I will add details about my approach and thought process here, as I work through the assignment. This way, you can follow my implementation easier.

# Requirements Gathering

## API Service
In order to complete this assignment, I will need to code a small service that serves some HTML and some REST APIs and communicates with the PokeAPI linked in the PDF. I can see that support has ended for PokeAPI version 1, so I will use v2 instead. 

[PokeAPI V2 Docs](https://pokeapi.co/docs/v2)

I will use Go and Gin for this API since it's my favorite language.

The PDF mentions that the user should be able to input a number, then receive some stats and an image describing a pokemon. Looking through the PokeAPI documentation, in the Pokemon section, I found out that each pokemon has an integer ID assigned to it. I will assume the integer entered by the user is the ID in PokeAPI.

Based on the number input, the PDF the page should display some stats and an image.
I played around with the API in Postman to see what kind of information I can get.
For the image, I see that the API provides a set of sprites for each pokemon. I am going to use the front_default and the front_shiny sprites since every pokemon must have one of these. I will stay away for the "other" image links because I'm not sure that all pokemon have it.

I will add the name, base experience, height, weight for basic information.

For the stats, I see that each pokemon has a list of stats of this shape:
```json
"stats": [
{
	"base_stat": 70,
	"effort": 2,
	"stat": {
		"name": "hp",
		"url": "https://pokeapi.co/api/v2/stat/1/"
	}
},
{
	"base_stat": 45,
	"effort": 0,
	"stat": {
		"name": "attack",
		"url": "https://pokeapi.co/api/v2/stat/2/"
	}
},
{
	"base_stat": 48,
	"effort": 0,
	"stat": {
		"name": "defense",
		"url": "https://pokeapi.co/api/v2/stat/3/"
	}
},
// and so on...
],
```

Querying `https://pokeapi.co/api/v2/stat/` shows that there are only 9 different stats. So, instead of converting each stat name to Title Case or something, I could just hardcode them, since I don't think they will be adding more stats to Pokemon in the future.
I can list each stat in a table, displaying rows dynamically based on how many stats that pokemon has.

Therefore, we have a crude API schema:
```
id -> pokemon.id
name -> pokemon.name
base_experience -> pokemon.base_experience
height -> pokemon.height
weight -> pokemon.weight
stats[] -> pokemon.stats
```

Let's think about the security defenses of our API now. 
We would need to add input validation for the integer box, log each pokemon retrieval attempt and possibly also validate the response from PokeAPI, as we wouldn't want it to compromise the security of our application. 

For the pokemon image I think I have 2 options:
- either pass the image URL received from PokeAPI directly to the user, having their browser render it directly from the source
- or proxy the image and try to do some validation/sanitization myself

Since the PokeAPI repo seems fairly well-maintained and I don't think the focus of this interview is image validation, I will just pass the image directly to the user.

Great :) now we have our initial requirements for the API service. The next thing we should think about is our container setup. I know how to use docker-compose and nginx, but the PDF requires me to use Terraform to deploy them. I've never used Terraform before, so I would have to look at the docs.

# Using Terraform
It appears that the [Terraform docs](https://developer.hashicorp.com/terraform/tutorials/docker-get-started/docker-build) have a fairly straightforward tutorial for using it with the docker provider. I can add all the configuration for my containers directly there, similarly to docker-compose. 

I should also use a separate file for variables so I don't commit them into the repo. I see that the ability to create variables is provided, but I'm not sure that's the best practice for storing those values in a file. I asked Gemini on more info about this and it seems that I can declare variable schema in a `variables.tf` file and then have a `.tfvars` file with the actual values, which I will not commit into the repo.

If I also use `.auto.tfvars`, I see that they will used automatically when `terraform apply` is called, so that's the way for the moment.

### First Terraform Container
I'll start with the Terraform example, then add my modifications. I see that there is a newer version of the docker provider, so I'll bump the version to `4.5.0`.

I found a sample terraform .gitignore file. I'll copy the contents to my file in order to avoid commiting any sensitive data to the repo.

I see that I have to run these commands every time I checkout a terraform project:
- `terraform init` - to initialize the local terraform folder and install the required providers
- `terraform fmt` - to format my terraform configuration
- `terraform validate` - to validate the configuration

`terraform apply` applies the configuration. I can use `plan` to preview and verify the changes that will be applied.

![[terraform-test.png.png]]
Great, now I have my first container created by terraform :)

`terraform show` displays the currently applied configuration

# Back to Go
Let's circle back to our Go API container. I should think about how to build it. I could probably compile it at build time using a go image, but we can go a step further and decouple our build step from the running image.
I can use one container to compile the go binary, then copy it into a blank linux image, where I will actually run it. I'm going to start to try and figure that out. By chatting with Gemini and validating with the docker terraform provider docs, I found out that I can build my image using the provider.
Moreover,  I can use the `triggers` argument to rebuild my image whenever the source code changes.

```tf
resource "docker_image" "zoo" {
  name = "zoo"
  build {
    context = "."
  }
  triggers = {
    dir_sha1 = sha1(join("", [for f in fileset(path.module, "src/**") : filesha1(f)]))
  }
}
```

## Building the Image
To run the image, I will use a distroless container as my base, since it doesn't come with unix utils or a shell, lowering my attack surface. [Link to repo](https://github.com/googlecontainertools/distroless)

I built the go binary in a `builder` stage, with C compatibility disabled (because it's pure go), linux os target and `-ldflags="-w -s"` to omit debugging data from the binary in order to reduce the binary size, at Gemini's recommendation.

One thing to note for later, there isn't a go.sum file in the repo yet. I should also copy it when I build the container, to add extra protection against supply chain attacks.

## Implementing a mock API
In order to have something the nginx proxies to, I need some APIs served by my go container. I will use the Gin framework for this because it's the one I'm more experienced in and it's widely used, well known, and has pretty good documentation.
I asked Gemini to remind me of the best practice project structure, so that everything is tidy.

## Configuring the reverse proxy
Now, I need to configure nginx to proxy the traffic to the go API container. Normally, if I were to use Kubernetes, I would add the `nginx.conf` file inside a ConfigMap, but since we're using plain docker, I will need to pass the nginx configuration file in a different way. I'm thinking that I have 3 options:
- build a custom nginx container with the config baked in
- inject it as a volume
- or find a way to inject it from terraform

With Gemini's help, I found out that I can use upload blocks to copy the configuration file over to the nginx container.

Next, I hit the first roadblock. The nginx container does not resolve the API container. I found out that containers created using the docker terraform provider are attached to the default bridge network by default, where dns resolution of container names does not seem to work. I can solve this by creating an explicit network, which I wanted to do anyways, so I could have an isolated network where our nginx pod and the api container can communicate.

Turns out this was not the root cause. The issue was caused by a typo in my nginx config. I was proxying to `hh-api` but the container name was `hh_api`. Another problem was that nginx was listening on `8000` not `80`, as forwarded in the terraform configuration. I fixed both, but now I get a 502 Bad Gateway error when calling the API. I'm going to start debugging that now.

Turns out the 502 error was caused by a podman bug. Both containers were assigned the same IP. After destroying and re-applying the configuration, I managed to get it working properly.

## Implementing the required APIs
Now that I got the basic infrastructure working, I'll move on to actually implementing the APIs that we need. I created a pokemon service that will query the PokeAPI to retrieve information about the requested pokemon. Next, I will create a Pokemon type in the `domain` package, which will represent the information about our pokemon that we want to return to the user.

In order to simplify the code, I will return the same structure that I receive from PokeAPI, with some fields omitted. This allows me to use the same type for retrieving and returning the data. The initial model also did not contain sprite data, so I added support for `front_default` and `front_shiny` sprites.