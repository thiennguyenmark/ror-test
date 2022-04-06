# README

Welcome to ReferReach's Ruby on Rails technical test.

## STEPS

1. Fork this project to your account.
2. Create a local clone.
3. For each question answered, commit your answers in a single commit and identify the answered question in the commit message. For example, ``git commit -m 'Answer #1.1'``
4. When you are ready to have your answers reviewed, make a Pull Request.

## QUESTIONS

There are **10** questions altogether: 1.1 (i) - 1.2 (ii), 2.1 (i), 3.1 (i) - 3.5 (v), 4.1(i), and 5.1 (i).

**If you are applying to be a mid-senior level engineer, please ensure you complete Question 3.5 (v) and 4.1 (i).**

1. ActiveViews

    1. There are 2 existing models - `Book` and `Author`. A `Book` must `belong_to` to an `Author`.

       However, the current view for `BooksController#create` does not allow any new books to be created. [Try it](http://localhost:3000/books/new).

       Make a fix to ensure that this will work.

    2. Update the view to allow also a new Author to be created without having to visit [Create New Author](http://localhost:3000/authors/new) page.

2. ActiveStorage / CarrierWave

   You can use either **ActiveStorage** or **CarrierWave**.

    1. Create an `Image` model and a corresponding uploader for it.

       The uploader should save the original uploaded image and a thumbnail version. Thumbnail version should fit within a canvas of 150 x 150 pixels.

       Metadata for the `Image` would be `Title` and `Description`

3. Analytics (High Performance)

   In this section, we will be building a high performance analytics/event data store.

    1. Create a model (no scaffold or controllers required) suitable for processing analytics data. You can choose to use a different database for this.

       A typical record would contain `event`, `value`, and `event_time` fields.

       Once a analytics record is created, it cannot be updated. Ensure you remove unnecessary methods and fields.

    2. Build a module or library that will allow insertion of analytics data. For example, a typical call would be:

       ``Analytics.event(:login, user.nickname)``

    3. Using Sidekiq, create a worker that would do the insertions in the background and update Analytics.event to use this worker.

    4. Add a method that would allow bulk insertion of analytics data.

       For example:

       ```
       Analytics.events([
            [:login, user.nickname, Time.now],
            [:logout, user.nickname, Time.now]
       ])
       ```

    5. **(Advance)** Update the single event logging method to use a thread-safe queue that will combine multiple calls to `.event` to the bulk version `.events`.

       The example below

       ```
       (1..50).each do |index|
            Analytics.event(:random, index)
       end
       ```

       will, in a background thread, be converted to something like:

       ```
       Analytics.events([
            [:random, 1, Time.now],
            [:random, 2, Time.now],
            [:random, 3, Time.now],
            ..
            ..
            [:random, 23, Time.now]
       ])

       Analytics.events([
            [:random, 24, Time.now],
            [:random, 25, Time.now],
            [:random, 26, Time.now],
            ..
            ..
            [:random, 50, Time.now]
       ])
       ```
4. Meta-Programming / Data Structures

   1. Here at Fulfilled, we are big of the DRY principle and meta programming to build reusable modules.

      We would like to you build a module and a model to do the following:

      ```
      class MyMetadataClass
        include MetadataAccessor

        attr_accessor :temp_data
        metadata_accessor :temp_data, as: :metadata
      end

      >> k = MyMetadataClass.new

      >> k.temp_data
      nil

      >> k.metadata_set('user.nickname', 'sally')

      >> k.temp_data
      {
        user: {
          nickname: 'sally'
        }
      }

      >> k.metadata_get('user.name')
      nil
      ```

      The method `metadata_accessor` is used to define the method name used to store/retrieve the hash containing metadata.

      There is an optional `as` parameter to allow an alternative name to be used for the `_get` and `_set` methods. In the above example, if `as` is not specified, the methods will be called `temp_data_set` and `temp_data_get`.

      When setting values, the hash and internal hashes should automatically be created.

5. ReactJS

   In the root of this RoR project, create a new folder called `reactjs`. This will be your ReactJS project root.

    1. Create a new ReactJS project that uses redux and react-router and create a simple interface that allows a user to list, create, edit and delete Books and Authors.

       Your application should use the RoR project's JSON APIs to do this.
