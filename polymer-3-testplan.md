# Polymer 3 Overall Test Plan
## Web component Conversion
Polymer 3 Roll out plan will be to convert the web components first.

### Component Upgrade to Polymer 3 Testing
The testing for this will include 
* developers using Polymer test command testing (https://github.com/BrightspaceUI/guide/wiki/Testing#testing-with-polymer-test)
* Unit/integration tests as part of the CI pipeline
* Demo page testing of the component
  * This might be a good page to use perceptual diff tool against.
  * These pages are also be a good candidate for cross platform/browser testing
 
**Question:** If the demo page is not present or not built properly should time be invested cleaning these pages up. Would it benefit future projects when we upgrade again or move to something other than polymer. 

## Testing of the integration of new Polymer 3 components into a page.
 
### Manual Testing
Manual testing needs to include both the look of the component as well as the functionality.
Since not all web components use the same functionality in each place it is used its important to understand all functionality and test them where they are used in at least one place.  We can see the different states in the demo page but the actual use in the LMS may uncover other defects. 
E.g. DE31831 where the count functionality in a css isn't being accounted for. 
 
Once tools/pages/apps/widgets start using the new components integration type testing can be started.
This testing should include
 * Look of the component
  * Size
  * Placement
  * Padding
  * Text alignment
  * Animation
* Different states of the component
  * Selected/unselected
  * Hover
  * Open/closed
  * Enabled/disabled
  * Etc
* Functionality called by the component
* Functionality within the tool/page/app/widget
* Accessiblity
  * Ensure objects are still keyboard only friendly
  * Ensure screen readers work with the objects.
  * Ensure components meet WCAG 2.0 requirements
 
## Risks.
* Having Shadow DOM on is a risk as its off by default in Polymer 1 and we know there are issues with Polymer and shadow DOM being on 
  * To mitigate this risk testing can be done with Polymer 1 with shadow DOM on. (See Shadow Dom Pre-Testing for details.
* Not all of the LMS will be ready to convert for the same releases.
  * Ensure timelines are well communicated, any pre-testing is done. 
 
 
## Shadow DOM Pre-testing
Testing of shadow DOM being turned on with Polymer 1 can help catch and fix issues with our existing software even before the move to Polymer 3. 
This testing can be done via the following methods
* Enable shadow DOM by just adding `?dom=shadow` (or `&dom=shadow` if there’s already a query-string) to the page URL. 
  * This will only last for that page, if you navigate somewhere you need to add it again.
* You can enable shadow DOM site-wide using the `polymer1-shadow-dom` feature flag. This flag isn’t meant to be enabled in prod, it’s just for testing this out. 
  * https://git.dev.d2l/projects/COM/repos/lms-launch-darkly-flags/browse/features/web-platform/polymer1-shadow-dom.feature.json
* If you find an issue and you want to confirm it is due to the shadow DOM being on then you can add ?dom=shady to the end of the URL while the flag is on. 
E.g. https://qa108813820g.bspc.com/d2l/home?dom=shady
 
### Things of Note with Shadow DOM pre-testing
* Chrome only
* You can confirm shadow DOM is enabled by inspecting the source of a web component (e.g. my courses) and seeing `#shadow-root`s in the DOM tree
 
### Areas to watch for when testing the different pages. 
* Look for changes in the UI
* Animations
* Tables
* Page Overlays
* More/less
* Uses of CSS 
* Use of longer text
* RTL
* Functionality can be affected as well
* Accessiblity
  * Ensure objects are still keyboard only friendly
  * Ensure screen readers work with the objects.
  
**Note:** ARIA “*-by” ids may be blocked from the corresponding labels/texts in Shadow DOM
 
### Logging Defects against Polymer 1 components with shadow DOM on.
To help keep track of issues found during this shadow DOM pre-testing we are asking that they be flagged with the tag ShadowDOM
The defects are to be assigned to the team that 'owns' the page being tested. 
 
### Current list of Issues Found 
This list will not be constantly updated. This list is to be used as examples of issues found to help guide teams with their own testing.

|ID |	Name| 
| --- | --- | 
| DE31831	| Polymer 3 > Shadow DOM > My Courses Widget. With Shadow DOM on in Polymer 1 the My courses widget is showing 20 courses instead of 12 |
| DE31799	| Polymer 3 > shadow DOM > Navbar - changing the link area colour for the Navbar isn't shown when shadow DOM is on |
| DE31778	| Polymer 3 > Shadow DOM > My Courses Widget > Course cards lose padding when Shadow DOM is turned on. |
