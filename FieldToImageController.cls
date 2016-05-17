public class FieldToImageController {
    public Integer lineHeight { get; set; }

    public String textWidth { get; set; }

    public String textHeight { get; set; }
    
    public List<String> lineList { get; set; }
    
    public List<String> lineY { get; set; }
    
    public FieldToImageController() {
        // collect parameters and defaults
        String objectName = ApexPages.CurrentPage().getParameters().get( 'object' );
        String fieldName = ApexPages.CurrentPage().getParameters().get( 'fieldName' );
        String theID = ApexPages.CurrentPage().getParameters().get( 'id' );
        String wrapSize = ApexPages.CurrentPage().getParameters().get( 'wrap' );
        Integer maximumCharsPerLine = 40;
        if( wrapSize != null ) {
            maximumCharsPerLine = Integer.valueOf( wrapSize );
        }
        
        lineHeight = 16;
        
        // fetch the field and convert to text
        List<SObject> objList = Database.query( 'SELECT ID, ' + fieldName + ' FROM ' + objectName 
                + ' WHERE ID = \'' + theID + '\' LIMIT 1' );
        if( objList.size() <= 0 ) {
            return;
        }
        String rawText = String.valueOf( objList[ 0 ].get( fieldName ) );
        if( rawText == null ) {
            return;
        }
        rawText = rawText.replace( '<', '&lt;' ).replace( '&', '&amp;' );
        
        lineList = new List<String>();
        lineY = new List<String>();
        
        // compose lines of text and wrap words when they exceed the maximum characters per line
        String line = '';
        List<String> wordList = rawText.split( ' ' );
        for( Integer n = 0; n < wordList.size(); n++ ) {
            String testLine = line + wordList[ n ] + ' ';
            if( testLine.length() <= maximumCharsPerLine ) {
                line = testLine;
                continue;
            }
            lineList.add( line );
            lineY.add( String.valueOf( lineHeight * lineList.size() ) );
            line = wordList[ n ] + ' ';
        }
        if( line != '' ) {
            lineList.add( line );
            lineY.add( String.valueOf( lineHeight * lineList.size() ) );
        }
        
        // calculate image size to accomodate the wrapped text
        textWidth = String.valueOf( maximumCharsPerLine * 7 );
        Integer heigth = lineHeight * lineList.size() + 4;
        textHeight = String.valueOf( heigth );
        
    }
}