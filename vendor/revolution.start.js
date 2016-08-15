function renderElement (element) {
  var svg = d3.select('svg'),
    d3_el = svg.append('g'),
    node  = d3_el.append(element.type=='text' ? 'rect' : element.type);

    
}

$(document).ready(function () {

  var winWidth  = $(window).width(),
    winHeight = $(window).height(),

    scaleX = winWidth / 700,
    scaleY = winHeight / 500;

  console.log my_project

  for (var i=0, l=my_project.slides.length; i<l; i++) {
    for (var j=0, _l=my_project.slides[i].elements.length; j<_l; j++) {
      element = my_project.slides[i].elements[j];
    }
  }

});