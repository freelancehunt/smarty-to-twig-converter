Freelancehunt usage
===================================
For the 1st usage build a Docker image and install Composer dependencies:
```
docker build -t fh_twig_converter .
docker run -it --rm --name twigConverter -v $PWD:/app fh_twig_converter composer install
```
Then run a converter against required Smarty template or directory:
```
./convert.sh ~/freelancehunt.com/smarty_templates/tailwind_templates/base.tpl
./convert.sh ~/freelancehunt.com/smarty_templates/tailwind_templates
```

To use a debugger you have to configure server in PHPStorm(Settings -> PHP -> Servers) with name "smarty2twig" and map the repository folder to `/app`.

Converting tool located atConverting Smarty templates to Twig
===================================

Converting tool located at
[GitHub](https://github.com/OXID-eSales/oxideshop-to-twig-converter)
allows to convert existing Smarty template files to Twig syntax. The
tool besides standard Smarty syntax is adjusted to handle custom OXID
modifications and extensions.

### Installation

Clone the repository:

`git clone https://github.com/OXID-eSales/smarty-to-twig-converter.git`

Install dependencies:

`cd smarty-to-twig-converter`

`composer install`

### Usage

The convert command tries to fix as much coding standards problems as
possible on a given file, directory or database.

### path and ext parameters

Converter can work with files and directories:

`php toTwig convert --path=/path/to/dir`
`php toTwig convert --path=/path/to/file`

By default files with `.html.twig` extension will be created. To specify
different extensions use `--ext` parameter:

`php toTwig convert --path=/path/to/dir --ext=.js.twig`

### database and database-columns parameters

It also can work with databases:

`php toTwig convert --database="mysql://user:password@localhost/db"`

The `--database` parameter gets [database doctrine-like
URL](https://www.doctrine-project.org/projects/doctrine-dbal/en/2.9/reference/configuration.html#connecting-using-a-url).
Converter by default converts following tables columns:
- oxactions.OXLONGDESC
- oxactions.OXLONGDESC_1
- oxactions.OXLONGDESC_2
- oxactions.OXLONGDESC_3
- oxcontents.OXCONTENT
- oxcontents.OXCONTENT_1
- oxcontents.OXCONTENT_2
- oxcontents.OXCONTENT_3
- oxartextends.OXLONGDESC
- oxartextends.OXLONGDESC_1
- oxartextends.OXLONGDESC_2
- oxartextends.OXLONGDESC_3
- oxcategories.OXLONGDESC
- oxcategories.OXLONGDESC
- oxcategories.OXLONGDESC_2
- oxcategories.OXLONGDESC_3

The `--database-columns` option lets you choose tables columns to be
converted (the table column names has to be specified in
table\_a.column\_b format and separated by comma):

`php toTwig convert --database="..." --database-columns=oxactions.OXLONGDESC,oxcontents.OXCONTENT`

You can also blacklist the table columns you don't want using
-table\_a.column\_b:

`php toTwig convert --database="..." --database-columns=-oxactions.OXLONGDESC_1,-oxcontents.OXCONTENT_1`

### converters parameter

The `--converters` option lets you choose the exact converters to apply
(the converter names must be separated by a comma):

`php toTwig convert --path=/path/to/dir --ext=.html.twig --converters=for,if,misc`

You can also blacklist the converters you don't want if this is more
convenient, using -name:

`php toTwig convert --path=/path/to/dir --ext=.html.twig --converters=-for,-if`

### dry-run, verbose and diff parameters

A combination of `--dry-run`, `--verbose` and `--diff` will display
summary of proposed changes, leaving your files unchanged.

All converters apply by default.

The `--dry-run` option displays the files that need to be fixed but
without actually modifying them:

`php toTwig convert --path=/path/to/code --ext=.html.twig --dry-run`

### config-path parameter

Instead of building long line commands it is possible to inject PHP
configuration code. Two example files are included in main directory:
`config_file.php` and `config_database.php`. To include config file use
--config-path parameter:

`php toTwig convert --config-path=config_file.php`

Config script should return instance of `toTwig\Config\ConfigInterface`.
It can be created using `toTwig\Config\Config::create()` static method.


### Known issues


-   In Twig by default all variables are escaped. Some of variables
    should be filtered with `|raw` filter to avoid this. This means all
    templates, html code and strings containing unsafe characters like `< > $ &`
    should be filtered with `|raw` before echoing. You can check if all necessary 
    variables are escaped using web browser's inspector tool.
    Instead of using `raw` filter to echo variable holding a template, you 
    can use `template_from_string` function.  More on it in the [documentation](https://twig.symfony.com/doc/1.x/functions/template_from_string.html).
    
    Smarty:
    ```smarty
    [{$product->oxarticles__oxtitle->value}]
    ```
    Twig after converting:
    ```twig
    {{ product.oxarticles__oxtitle.value }}
    ```
    Twig after fixing:
    ```twig
    {{ product.oxarticles__oxtitle.value|raw }}
    ```

-   Variable scope. In Twig variables declared in templates have scopes
    limited by block (`{% block %}`, `{% for %}` and so on). Some
    variables should be declared outside these blocks if they are used
    outside.
    
    Smarty:
    ```smarty
    [{foreach $myColors as $color}]
        <li>[{$color}]</li>
    [{/foreach}]
    [{$color}]
    ```
    Twig after converting:
    ```twig
    {% for color in myColors %}
        <li>{{ color }}</li>
    {% endfor %}
    {{ color }}
    ```
    Twig after fixing:
    ```twig
    {% for color in myColors %}
        <li>{{ color }}</li>
    {% endfor %}
    {{ myColors|last }}
    ```

-   Redeclaring blocks - it’s forbidden in Twig. You must use a unique
    name for each block in given template.
    
    Smarty:
    ```smarty
    [{block name="foo"}]
        ...
    [{/block}]
    [{block name="foo"}]
        ...
    [{/block}]
    ```
    Twig after converting:
    ```twig
    {% block foo %}
        ...
    {% endblock %}
    {% block foo %}
        ...
    {% endblock %}
    ```
    Twig after fixing:
    ```twig
    {% block foo_A %}
        ...
    {% endblock %}
    {% block foo_B %}
        ...
    {% endblock %}
    ```

-   Access to array item `$myArray.$itemIndex` should be manually
    translated to `myArray[itemIndex]`
    
    Smarty:
    ```smarty
    [{$myArray.$itemIndex}]
    ```
    Twig after converting:
    ```twig
    {{ myArray.$itemIndex }}
    ```
    Twig after fixing:
    ```twig
    {{ myArray[itemIndex] }}
    ```

-   Uses of regex string in templates - the tool can break or work
    incorrectly on so complex cases - it’s safer to manually copy&paste
    regular expression.
    
    Smarty:
    ```smarty
    [{birthDate|regex_replace:"/^([0-9]{4})[-]/":""|regex_replace:"/[-]([0-9]{1,2})$/":""}]
    ```
    Twig after converting:
    ```twig
    {{ birthDate|regex_replace("/^([0-9]{4)})[-]/":""|regex_replace("/[-]([0-9]{1,) 2})$/":"" }}
    ```
    Twig after fixing:
    ```twig
    {{ birthDate|regex_replace("/^([0-9]{4})[-]/","")|regex_replace("/[-]([0-9]{1,2})$/","") }}
    ```

-   `[{section}]` - `loop` is array or integer which triggers different
    behaviours. The tool is not able to detect variable type, so you need to check
    what is used in each `loop`.
    
    Smarty:
    ```smarty
    [{section name="month" start=1 loop=13}]
        [{$smarty.section.month.index}]
    [{/section}]
    [{section name=customer loop=$custid}]
        id: [{$custid[customer]}]<br />
    [{/section}]
    ```
    Twig after converting:
    ```twig
    {% for month in 1..13 %}
        {{ loop.index0 }}
    {% endfor %}
    {% for customer in 0..$custid %}
        id: {{ custid[customer] }}<br />
    {% endfor %}
    ```
    Twig after fixing:
    ```twig
    {% for month in 1..12 %}
        {{ loop.index0 }}
    {% endfor %}
    {% for customer in custid %}
        id: {{ customer }}<br />
    {% endfor %}
    ```

-   String concatenation - the tool has issues with opening and closing strings.
    Usage of Smarty variables inside the string might cause the converter to fail.
	Twig does not support this kind of concatenation. You should check places
	where you concat strings held inside variables and use Twig `~` instead of 
	variables inside the string. In converted template you should look for
	patterns like \`$var_name\`
    
    Smarty:
    ```smarty
    [{assign var="sUrl" value="http://www.example.com?aid=`$sAccountId`&wid=`$sWidgetId`&csize=20&start=0"}]
    [{assign var="divId" value=oxStateDiv_$stateSelectName}]
    ```
    Twig after converting:
    ```twig
    {% set sUrl = "http://www.example.com?aid=`$sAccountId`&wid=`$sWidgetId`&csize=20&start=0" %}
    {% set divId = oxStateDiv_$stateSelectName %}
    ```
    Twig after fixing:
    ```twig
    {% set sUrl = "http://www.example.com?aid=" ~ sAccountId ~ "&wid=" ~ sWidgetId ~ "&csize=20&start=0" %}
    {% set divId = "oxStateDiv_" ~ stateSelectName %}
    ```

-   `$` signs are not always removed from variables. Sometimes when expression
    is too complex, the converter will not remove `$` sign from variable name.
	After conversion you should check your templates for `$` signs.
    
    Smarty:
    ```smarty
    [{$oViewConf->getImageUrl($sEmailLogo, false)}]
    ```
    Twig after converting:
    ```twig
    {{ oViewConf.getImageUrl($sEmailLogo, false) }}
    ```
    Twig after fixing:
    ```twig
    {{ oViewConf.getImageUrl(sEmailLogo, false) }}
    ```

-   Twig offers easy access to fist element of loop. Instead of using indexed
    element of variable you can use `loop.index0` or for current iteration
	`loop.index`. Converter does not handle constructions like `$smarty.section.arg`.
	More can be read in the [Twig 'for' documentation](https://twig.symfony.com/doc/2.x/tags/for.html).
    
    Smarty:
    ```smarty
    [{if $review->getRating() >= $smarty.section.starRatings.iteration}]
    ```
    Twig after converting:
    ```twig
    {% if review.getRating() >= smarty.section.starRatings.iteration %}
    ```
    Twig after fixing:
    ```twig
    {% if review.getRating() >= loop.index %}
    ```

-   In some places access to global variables has to be adjusted. In converted code
    look for word `smarty` and replace it with `twig`.
    
    Smarty:
    ```smarty
    [{$smarty.capture.loginErrors}]
    ```
    Twig after converting:
    ```twig
    {{ smarty.capture.loginErrors }}
    ```
    Twig after fixing:
    ```twig
    {{ twig.capture.loginErrors }}
    ```

-   Properties accessing differs in Smarty and Twig and sometimes it has to be fixed manually. You have to explicitly
    call magic getter if there is no magic isset defined. Also if you want to access class property without calling
    a getter you have to use array-like syntax.
    
    Smarty:
    ```smarty
    [{foreach from=$cattree->aList item=pcat}]
        [{pcat.val}]
    ```
    Twig after converting:
    ```twig
    {% for pcat in cattree.aList %}
        {{ pcat.val }}
    ```
    Twig after fixing:
    ```twig
    {% for pcat in cattree.__get('aList') %}
        {{ pcat['val'] }}
    ```

-   The converter does not always convert logic operators like `||` and `&&` if they
    are not separated by space. `||` has to be manually changed to `or` and `&&` to `and`.
    
    Smarty:
    ```smarty
    [{if $product->isNotBuyable()||($aVariantSelections&&$aVariantSelections.selections)||$product->hasMdVariants()}]
    ```
    Twig after converting:
    ```twig
    {% if product.isNotBuyable()||(aVariantSelections&&$aVariantSelections.selections) or product.hasMdVariants() %}
    ```
    Twig after fixing:
    ```twig
    {% if product.isNotBuyable() or (aVariantSelections and aVariantSelections.selections) or product.hasMdVariants() %}
    ```

-   If you access request variables from template, please consider refactoring
    any templates that do this. If it is not possible, please use functions
	`get_global_cookie` or `get_global_get` provided with Twig engine.
	In case you need access to other request variables, you will have to
	extend one of these functions on your own.
    
    Smarty:
    ```smarty
    [{if $smarty.get.plain == '1'}] popup[{/if}]
    ```
    Twig after converting:
    ```twig
    {% if smarty.get.plain == '1' %} popup{% endif %}
    ```
    Twig after fixing:
    ```twig
    {% if get_global_get('plain') == '1' %} popup{% endif %}
    ```

-   You might need to manually check logic in template files. Some places will
    require usage of `is same as` comparison, which uses PHP's `===` instead of `==`. 
	This might be necessary when checking if variable was set, contains information,
	if it is a `0` or if it is a `null`. There is a problem with checking
	non existing (null) properties. E.g. we want to check the value of
	non-existing property `oxarticles__oxunitname`. Twig checks with `isset`
	if this property exists and it’s not, so Twig assumes that
	property name is function name and tries to call it.
    
    Smarty:
    ```smarty
    [{if $_sSelectionHashCollection}]
        [{assign var="_sSelectionHashCollection" value=$_sSelectionHashCollection|cat:","}]
    [{/if}]
    ```
    Twig after converting:
    ```twig
    {% if _sSelectionHashCollection %}
        {% set _sSelectionHashCollection = _sSelectionHashCollection|cat(",") %}
    {% endif %}
    ```
    Twig after fixing:
    ```twig
    {% if _sSelectionHashCollection is not same as("") %}
        {% set _sSelectionHashCollection = _sSelectionHashCollection|cat(",") %}
    {% endif %}
    ```

### Converted plugins and syntax pieces

Here is list of plugins and syntax pieces with basic examples how it is
converted. Note that these examples are only to show how it is converted
and doesn't cover all possible cases as additional parameters, block
nesting, repetitive calls (as for counter and cycle functions) etc.

### Core Smarty

#### assign =\> set

Converter name: `assign`

Smarty:\
`[{assign var="name" value="Bob"}]`

Twig:\
`{% set name = "Bob" %}`

#### block =\> block

Converter name: `block`

Smarty:\
`[{block name="title"}]Default Title[{/block}]`

Twig:\
`{% block title %}Default Title{% endblock %}`

#### capture =\> set

Converter name: `CaptureConverter`

Smarty:\
`[{capture name="foo" append="var"}] bar [{/capture}]`

Twig:\
`{% set foo %}{{ var }} bar {% endset %}`

#### Comments

Converter name: `comment`

Smarty:\
`[{* foo *}]`

Twig:\
`{# foo #}`

#### counter =\> set

Converter name: `counter`

Smarty:\
`[{counter}]`

Twig:\
`{% set defaultCounter = ( defaultCounter|default(0) ) + 1 %}`

#### cycle =\> smarty\_cycle

Converter name: `cycle`

Smarty:\
`[{cycle values="val1,val2,val3"}]`

Twig:\
`{{ smarty_cycle(["val1", "val2", "val3"]) }}`

#### foreach =\> for

Converter name: `for`

Smarty:\
`[{foreach $myColors as $color}]foo[{/foreach}]`

Twig:\
`{% for color in myColors %}foo{% endfor %}`

#### if =\> if

Converter name: `if`

Smarty:\
`[{if !$foo or $foo->bar or $foo|bar:foo["hello"]}]foo[{/if}]`

Twig:\
`{% if not foo or foo.bar or foo|bar(foo["hello"]) %}foo{% endif %}`

#### include =\> include

Converter name: `include`

Smarty:\
`[{include file='page_header.tpl'}]`

Twig:\
`{% include 'page_header.tpl' %}`

#### insert =\> include

Converter name: `insert`

Smarty:\
`[{insert name="oxid_tracker" title="PRODUCT_DETAILS"|oxmultilangassign product=$oDetailsProduct cpath=$oView->getCatTreePath()}]`

Twig:\
`{% include "oxid_tracker" with {title: "PRODUCT_DETAILS"|oxmultilangassign, product: oDetailsProduct, cpath: oView.getCatTreePath()} %}`

#### mailto =\> mailto

Converter name: `mailto`

Smarty:\
`[{mailto address='me@example.com'}]`

Twig:\
`{{ mailto('me@example.com') }}`

#### math =\> core Twig math syntax

Converter name: `math`

Smarty:\
`[{math equation="x + y" x=1 y=2}]`

Twig:\
`{{ 1 + 2 }}`

#### Variable conversion

Converter name: `variable`

  |Smarty                          |Twig
  |------------------------------- |-----------------------------
  |[{$var}]                        |{{ var }}|
  |[{$contacts.fax}]               |{{ contacts.fax }}|
  |[{$contacts[0]}]                |{{ contacts[0] }}|
  |[{$contacts[2][0]}]             |{{ contacts[2][0] }}|
  |[{$person->name}]               |{{ person.name }}|
  |[{$oViewConf->getUrl($sUrl)}]   |{{ oViewConf.getUrl(sUrl) }}
  |[{($a && $b) &vert;&vert; $c}]  |{{ (a and b) or c }}|

#### Other

Converter name: `misc`

  |Smarty                          |Twig|
  |------------------------------- |----------------------------------------|
  |[{ldelim}]foo[{ldelim}]         |foo|
  |[{literal}]foo[{/literal}]      |{# literal #}foo{# /literal #}|
  |[{strip}]foo[{/strip}]          |{% spaceless %}foo{% endspaceless %}|

### OXID custom extensions

#### oxcontent =\> include_content

Converter name: `oxcontent`

Smarty:\
`[{oxcontent ident='oxregisteremail'}]`

Twig:\
`{% include_content 'oxregisteremail' %}`

#### oxeval =\> include(template\_from\_string())

Converter name: `OxevalConverter`

Smarty:\
`[{oxeval var=$variable}]`

Twig:\
`{{ include(template_from_string(variable)) }}`

#### oxgetseourl =\> seo\_url

Converter name: `oxgetseourl`

Smarty:\
`[{oxgetseourl ident=$oViewConf->getSelfLink()|cat:"cl=basket"}]`

Twig:\
`{{ seo_url({ ident: oViewConf.getSelfLink()|cat("cl=basket") }) }}`

#### oxhasrights =\> hasrights

Converter name: `oxhasrights`

Smarty:\
`[{oxhasrights object=$edit readonly=$readonly}]foo[{/oxhasrights}]`

Twig:\
`{% hasrights { "object": "edit", "readonly": "readonly", } %}foo{% endhasrights %}`

#### oxid\_include\_dynamic =\> include\_dynamic

Converter name: `oxid_include_dynamic`

Smarty:\
`[{oxid_include_dynamic file="form/formparams.tpl"}]`

Twig:\
`{% include_dynamic "form/formparams.tpl" %}`

#### oxid\_include\_widget =\> include\_widget

Converter name: `oxid_include_widget`

Smarty:\
`[{oxid_include_widget cl="oxwCategoryTree" cnid=$oView->getCategoryId() deepLevel=0 noscript=1 nocookie=1}]`

Twig:\
`{{ include_widget({ cl: "oxwCategoryTree", cnid: oView.getCategoryId(), deepLevel: 0, noscript: 1, nocookie: 1 }) }}`

#### oxifcontent =\> ifcontent

Converter name: `oxifcontent`

Smarty:\
`[{oxifcontent ident="TOBASKET" object="aObject"}]foo[{/oxifcontent}]`

Twig:\
`{% ifcontent ident "TOBASKET" set aObject %}foo{% endifcontent %}`

#### oxinputhelp =\> include "inputhelp.tpl"

Converter name: `oxinputhelp`

Smarty:\
`[{oxinputhelp ident="foo"}]`

Twig:\
`{% include "inputhelp.tpl" with {'sHelpId': getSHelpId(foo), 'sHelpText': getSHelpText(foo)} %}`

#### oxmailto =\> oxmailto

Converter name: `oxmailto`

Smarty:\
`[{oxmailto address='me@example.com'}]`

Twig:\
`{{ mailto('me@example.com') }}`

#### oxmultilang =\> translate

Converter name: `oxmultilang`

Smarty:\
`[{oxmultilang ident="ERROR_404"}]`

Twig:\
`{{ translate({ ident: "ERROR_404" }) }}`

#### oxprice =\> format\_price

Converter name: `oxprice`

Smarty:\
`[{oxprice price=$basketitem->getUnitPrice() currency=$currency}]`

Twig:\
`{{ format_price(basketitem.getUnitPrice(), { currency: currency }) }}`

#### oxscript =\> script

Converter name: `oxscript`

Smarty:\
`[{oxscript include="js/pages/details.min.js" priority=10}]`

Twig:\
`{{ script({ include: "js/pages/details.min.js", priority: 10, dynamic: __oxid_include_dynamic }) }}`

#### oxstyle =\> style

Converter name: `oxstyle`

Smarty:\
`[{oxstyle include="css/libs/chosen/chosen.min.css"}]`

Twig:\
`{{ style({ include: "css/libs/chosen/chosen.min.css" }) }}`

#### section =\> for

Converter name: `section`

Smarty:\
`[{section name=picRow start=1 loop=10}]foo[{/section}]`

Twig:\
`{% for picRow in 1..10 %}foo{% endfor %}`

#### Filters

  |Smarty                 |Twig|
  |---------------------- |---------------------------|
  |smartwordwrap          |smart_wordwrap|
  |date_format            |date_format|
  |oxaddparams            |add_url_parameters|
  |oxaddslashes           |addslashes|
  |oxenclose              |enclose|
  |oxfilesize             |file_size|
  |oxformattime           |format_time|
  |oxformdate             |format_date|
  |oxmultilangassign      |translate|
  |oxmultilangsal         |translate_salutation|
  |oxnubmerformat         |format_currency|
  |oxtruncate             |truncate|
  |oxwordwrap             |wordwrap|

### Running database conversion PHPUnit tests

Note for CI: To run database conversion PHPUnit tests, sqlite is required. You can install it by running following commands:

    $ sudo apt-get install sqlite3
    $ sudo apt-get install php7.2-sqlite

## Bugs and Issues

If you experience any bugs or issues, please report them in the section **OXID eShop (all versions)** under category **Twig engine** of https://bugs.oxid-esales.com
