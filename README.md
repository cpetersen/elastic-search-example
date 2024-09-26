# README

This is a sample application used for isolating searchkick and elasticsearch queries.

There is a single model, `Page` which has `title` and `body` attributes. You can search it using ElasticSearch.

## Running the app

```
bundle install
rake db:migrate # uses SQLite
docker compose up # probably in another window, only starts elastic search
rails c # Open the console
```

## Creating a dataset

From the console:

```ruby
Page.create!(
  title: "The Quick Brown Fox",
  body: "The quick brown fox jumps over the lazy dog. This is a classic example used for typography."
)

Page.create!(
  title: "Guide to Wild Animals",
  body: "Learn about the brown fox, quick jaguars, and slow turtles in this wild guide."
)

Page.create!(
  title: "Introduction to Elasticsearch",
  body: "Elasticsearch is a distributed, RESTful search engine built on top of Lucene."
)

Page.create!(
  title: "Foxes and Their Habitats",
  body: "Foxes, including the quick red fox, are commonly found in forests, grasslands, and mountains."
)

Page.create!(
  title: "Wildlife Safari",
  body: "The safari experience lets you observe lions, tigers, and the quick fox in their natural habitats."
)

Page.create!(
  title: "Understanding Search Engines",
  body: "Search engines like Elasticsearch, Lucene, and Solr allow users to quickly retrieve relevant data."
)

Page.create!(
  title: "Advanced Lucene Query Syntax",
  body: "Learn advanced techniques like AND, OR, NOT, and proximity queries for better search results."
)

Page.create!(
  title: "Why Search Matters",
  body: "Search is an essential part of navigating the web, helping users find quick answers to their questions."
)

Page.create!(
  title: "Search Query Best Practices",
  body: "Use phrases, boolean operators, and negation for crafting more effective search queries."
)

Page.create!(
  title: "Foxes: A Detailed Overview",
  body: "Foxes come in many colors, such as red and brown. Some foxes are known for being quick and cunning."
)

Page.reindex
```

## `query_string`

### Testing Search

From the console:

```ruby
ActiveRecord::Base.logger.level = 1
{
  '"quick brown fox"' => "Phrase match",
  'quick AND fox' => "Boolean (AND) operator",
  'quick -brown' => "Negation",
  'title:quick AND body:fox' => "Field-specific search",
  'qui*' => "Wildcard",
  '"quick fox"~5' => "Proximity search"
}.each do |query, description|
  puts "Query: #{query}"
  puts "Description: #{description}"
  Page.search(
    body: {
      query: {
        query_string: {
          query: query,
          fields: ["*"]
        }
      }
    }
  ).each_with_index do |page, index|
    puts "#{index} Title: #{page.title}"
  end; nil
  puts "-------------"
end; nil
```

### Results

```ruby
Query: "quick brown fox"
Description: Phrase match
0 Title: The Quick Brown Fox
-------------
Query: quick AND fox
Description: Boolean (AND) operator
0 Title: The Quick Brown Fox
1 Title: Foxes and Their Habitats
2 Title: Foxes: A Detailed Overview
3 Title: Guide to Wild Animals
4 Title: Wildlife Safari
-------------
Query: quick -brown
Description: Negation
0 Title: Foxes and Their Habitats
1 Title: Understanding Search Engines
2 Title: Wildlife Safari
3 Title: Why Search Matters
-------------
Query: title:quick AND body:fox
Description: Field-specific search
-------------
Query: qui*
Description: Wildcard
0 Title: The Quick Brown Fox
1 Title: Guide to Wild Animals
2 Title: Foxes and Their Habitats
3 Title: Wildlife Safari
4 Title: Understanding Search Engines
5 Title: Why Search Matters
6 Title: Foxes: A Detailed Overview
-------------
Query: "quick fox"~5
Description: Proximity search
0 Title: Wildlife Safari
1 Title: Foxes and Their Habitats
2 Title: The Quick Brown Fox
3 Title: Guide to Wild Animals
-------------
```

## `simple_query_string`

### Testing Search

THESE RESULTS DON'T LOOK RIGHT

```ruby
ActiveRecord::Base.logger.level = 1
{
  '"quick brown fox"' => "Phrase match",
  'quick + fox' => "Boolean (AND) operator",
  'quick -brown' => "Negation",
  'title:quick AND body:fox' => "Field-specific search",
  'qui*' => "Wildcard",
  '"quick fox"~5' => "Proximity search"
}.each do |query, description|
  puts "Query: #{query}"
  puts "Description: #{description}"
  Page.search(
    body: {
      query: {
        simple_query_string: {
          query: query,
          fields: ["*"]
        }
      }
    }
  ).each_with_index do |page, index|
    puts "#{index} Title: #{page.title}"
  end; nil
  puts "-------------"
end; nil
```

### Results

```ruby
Query: "quick brown fox"
Description: Phrase match
0 Title: The Quick Brown Fox
-------------
Query: quick + fox
Description: Boolean (AND) operator
0 Title: The Quick Brown Fox
1 Title: Foxes and Their Habitats
2 Title: Foxes: A Detailed Overview
3 Title: Search Query Best Practices
4 Title: Advanced Lucene Query Syntax
5 Title: Guide to Wild Animals
6 Title: Wildlife Safari
7 Title: Why Search Matters
-------------
Query: quick -brown
Description: Negation
0 Title: The Quick Brown Fox
1 Title: Search Query Best Practices
2 Title: Advanced Lucene Query Syntax
3 Title: Foxes and Their Habitats
4 Title: Understanding Search Engines
5 Title: Wildlife Safari
6 Title: Why Search Matters
7 Title: Guide to Wild Animals
8 Title: Foxes: A Detailed Overview
-------------
Query: title:quick AND body:fox
Description: Field-specific search
0 Title: Foxes and Their Habitats
1 Title: The Quick Brown Fox
2 Title: Guide to Wild Animals
3 Title: Search Query Best Practices
4 Title: Advanced Lucene Query Syntax
5 Title: Foxes: A Detailed Overview
6 Title: Introduction to Elasticsearch
7 Title: Wildlife Safari
8 Title: Understanding Search Engines
9 Title: Why Search Matters
-------------
Query: qui*
Description: Wildcard
0 Title: The Quick Brown Fox
1 Title: Guide to Wild Animals
2 Title: Foxes and Their Habitats
3 Title: Wildlife Safari
4 Title: Understanding Search Engines
5 Title: Why Search Matters
6 Title: Foxes: A Detailed Overview
-------------
Query: "quick fox"~5
Description: Proximity search
0 Title: The Quick Brown Fox
1 Title: Advanced Lucene Query Syntax
2 Title: Wildlife Safari
3 Title: Foxes and Their Habitats
4 Title: Guide to Wild Animals
5 Title: Why Search Matters
6 Title: Foxes: A Detailed Overview
-------------
```