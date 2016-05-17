public class barCodeImageController {
    public String code { get; set; }
    public String height { get; set; }
    public String width { get; set; }
    public Decimal barWidth { get; set; }
    public String barSequence { get; set; }
    
    public static List<String> code128List = new List<String>
        { '212222', '222122', '222221', '121223', '121322', '131222', '122213', '122312', '132212', '221213'
        , '221312', '231212', '112232', '122132', '122231', '113222', '123122', '123221', '223211', '221132'
        , '221231', '213212', '223112', '312131', '311222', '321122', '321221', '312212', '322112', '322211'
        , '212123', '212321', '232121', '111323', '131123', '131321', '112313', '132113', '132311', '211313'
        , '231113', '231311', '112133', '112331', '132131', '113123', '113321', '133121', '313121', '211331'
        , '231131', '213113', '213311', '213131', '311123', '311321', '331121', '312113', '312311', '332111'
        , '314111', '221411', '431111', '111224', '111422', '121124', '121421', '141122', '141221', '112214'
        , '112412', '122114', '122411', '142112', '142211', '241211', '221114', '413111', '241112', '134111'
        , '111242', '121142', '121241', '114212', '124112', '124211', '411212', '421112', '421211', '212141'
        , '214121', '412121', '111143', '111341', '131141', '114113', '114311', '411113', '411311', '113141'
        , '114131', '311141', '411131', '211412', '211214', '211232', '2331112' };
    
    public List<String> barList { get; set; }
    
    public barCodeImageController() {
        // collect parameters and defaults
        code = ApexPages.CurrentPage().getParameters().get( 'code' );
        height = ApexPages.CurrentPage().getParameters().get( 'height' );
        String barWidthStr = ApexPages.CurrentPage().getParameters().get( 'barWidth' );
        String barType = ApexPages.CurrentPage().getParameters().get( 'type' );
        if( barType == null ) {
            barType = 'B';
        } else {
            barType = barType.toUpperCase();
        }
        
        barWidth = 3;
        if( barWidthStr != null ) {
            barWidth = Decimal.valueOf( barWidthStr );
        }
        Decimal x = barWidth * 5;
        Decimal y = barWidth * 2.5;
        Decimal barLength = barWidth * 35;
        Decimal fontSize = 8 * barWidth;
        Decimal deltaX = barWidth * 2;
        Decimal yText = barWidth * 45;
        if( height == null ) {
            height = String.valueOf( 50 * barWidth );
        }
        
        // this object will accumulate the sequence of bars/rectangles
        BarCode b = new BarCode();
        b.x = x;
        b.y = y;
        b.barLength = barLength;
        b.barWidth = barWidth;
        b.rectList = '';
        
        // add guard bar according to the type
        if( barType == 'A' ) {
            addEncodedChar( 103, b );
        }
        if( barType == 'B' ) {
            addEncodedChar( 104, b );
        }
        if( barType == 'C' ) {
            addEncodedChar( 105, b );
        }
        
        // add barcodes for each digit
        barList = new List<String>();
        for( Integer i = 0; i < code.length(); i++ ) {
            // determine position of this character below the barcode
            Decimal xText = deltaX + b.x;
            
            // append the bars for this character
            Integer codeIndex = code.codePointAt( i ) - 32;
            addEncodedChar( codeIndex, b );
            
            // place character below the respective bars
            b.rectList = b.rectList 
                 + '<text x=\'' + xText + '\' y=\'' + yText 
                 + '\' font-family=\'Arial\' font-size=\'' + fontSize 
                 + '\'>' + code.substring( i, i + 1 ) + '</text>\n';
        }
        
        // calculate the checksum, append the bars for the checksum
        addEncodedChar( getCheckSum( code, barType ), b );
        
        // add guard bar
        addEncodedChar( 106, b );
        
        // expose bars and dimensions
        width = String.valueOf( b.x );
        barSequence = b.rectList;
        
    }
    
    public class BarCode {
        public String rectList;
        public Decimal x;
        public Decimal y;
        public Decimal barWidth;
        public Decimal barLength;
    }
    
    public static void addEncodedChar( Integer codeIndex, BarCode b ) {
        String codeSeq = code128List[ codeIndex ];
        
        // add the bar sequence that correspond to this code
        String rectList = '';
        for( Integer j = 0; j < codeSeq.length(); j++ ) {
            // get the bar/space width
            Integer digit = Integer.valueOf( codeSeq.substring( j, j + 1 ) );
            Decimal w = b.barWidth * digit;
            
            // if this is an even width in the sequence, draw the bar as a rectangle 
            // with the specified width w 
            if( Math.mod( j, 2 ) != 1 ) {
                String rect = '<rect x=\''+ String.valueOf( b.x ) 
                        + '\' y=\''+ String.valueOf( b.y ) 
                        + '\' width=\''+ String.valueOf( w )
                        + '\' height=\''+ String.valueOf( b.barLength )
                        + '\' fill=\'black\' stroke-width=\'0\' />\n';
                rectList = rectList + rect;
            }
            
            // advance to the next bar/space
            b.x = b.x + w;
        }
        
        // append sequence of rectangles to the list
        b.rectList = b.rectList + rectList;
    }
    
    public static Integer getCheckSum( String code, String barType ) {
        Integer sum;
        if( barType == 'A' ) {
            sum = 103;
        }
        if( barType == 'B' ) {
            sum = 104;
        }
        if( barType == 'C' ) {
            sum = 105;
        }
        
        for( Integer i = 0; i < code.length(); i++ ) {
            sum = sum + ( i + 1 ) * ( code.codePointAt( i ) - 32 );
        }
        
        system.debug( 'Sum= ' + sum );
        sum = Math.mod( sum, 103 );
        system.debug( 'Remainder Mod 103 = ' + sum );
        
        return sum;

        //sum = sum + 32;
        
        //String asciiSequence = ' '.repeat( 32 )
        //    + ' !"#$%&\'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~';
        
        //return asciiSequence.substring( sum, sum + 1 );
    }

}