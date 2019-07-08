/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package Utils;

import java.io.PrintWriter;
import java.util.Iterator;
import java.util.Map;

/**
 *
 * @author Stephen
 */
public class MapOutput {
    private static void writeMapEntry(String key, Object value, boolean isLast, PrintWriter pw, String indentation) {
            pw.println(indentation + "\"" + key + "\",");
            String str = indentation;

            if (value instanceof String) {
                    str += "\"" + value + "\"";
            } else if (value instanceof Number) {
                    str += value;
            } else {
                    throw new RuntimeException("unknown value type (value = " + value + ")");
            }

            if (!isLast) {
                    str += ",";
            }

            pw.println(str);
    }

    public static void writeMap(Map<String, Object> map, PrintWriter pw, String indentation) {
            pw.println(indentation + "{");
            pw.println(indentation + "    \"entries\": [");

            Iterator it = map.entrySet().iterator();
            while (it.hasNext()) {
                    Map.Entry<String, Object> entry = (Map.Entry<String, Object>) it.next();
                    writeMapEntry(entry.getKey(), entry.getValue(), !it.hasNext(), pw, indentation + "        ");
            }

            pw.println(indentation + "    ],");
            pw.println(indentation + "    \"$type\": \"kOS.Safe.Encapsulation.Lexicon\"");
            pw.println(indentation + "}");
    }
}
