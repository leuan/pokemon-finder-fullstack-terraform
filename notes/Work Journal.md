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

## Using Terraform
It appears that the [Terraform docs](https://developer.hashicorp.com/terraform/tutorials/docker-get-started/docker-build) have a fairly straightforward tutorial for using it with the docker provider. I can add all the configuration for my containers directly there, similarly to docker-compose. 

I should also use a separate file for variables so I don't commit them into the repo. I see that the ability to create variables is provided, but I'm not sure that's the best practice for storing those values in a file. I asked Gemini on more info about this and it seems that I can declare variable schema in a `variables.tf` file and then have a `.tfvars` file with the actual values, which I will not commit into the repo.

If I also use `.auto.tfvars`, I see that they will used automatically when `terraform apply` is called, so that's the way for the moment.

### First Terraform Container
I'll start with the Terraform example, then add my modifications. I see that there is a newer version of the docker provider, so I'll bump the version to `4.5.0`.

I found a sample terraform .gitignore file. I'll copy the contents to my file in order to avoid commiting any sensitive data to the repo.
