// tag::copyright[]
/*******************************************************************************
 * Copyright (c) 2017, 2022 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - Initial implementation
 *******************************************************************************/

// end::copyright[]
import java.io.IOException;
import java.io.PrintWriter;

import jakarta.annotation.Resource;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.annotation.HttpConstraint;
import jakarta.servlet.annotation.ServletSecurity;

import java.sql.Connection;
import javax.sql.DataSource;
import java.sql.SQLException;
import java.sql.Statement;
// import javax.annotation.Resource;
// import java.sql.ResultSet;
// import javax.naming.InitialContext;
// import javax.naming.NamingException;

@WebServlet(urlPatterns = "/servlet")
@ServletSecurity(value = @HttpConstraint(rolesAllowed = { "user",
        "admin" }, transportGuarantee = ServletSecurity.TransportGuarantee.CONFIDENTIAL))
public class HelloServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    // @Resource(lookup = "jdbc/exampleDS")
    @Resource(lookup = "jdbc/db2DS")
    DataSource ds1;

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Statement stmt = null;
        Connection con = null;
        try {
            // ds1 = (DataSource) new InitialContext().lookup("jdbc/exampleDS");
            // ds1 = (DataSource) new InitialContext().lookup("jdbc/db2DS");

            response.setContentType("text/html");
            PrintWriter out = response.getWriter();
            out.println("<H1>Hello World Liberty</H1>\n");
            out.println("Hello! How are you today?\n");
            try {
                con = ds1.getConnection();
                out.println("<p>Got a connection\n");
                stmt = con.createStatement();
                out.println("<p>Got a statement\n");
            } catch (SQLException e) {
                e.printStackTrace();
            } finally {
                if (stmt != null) {
                    try {
                        stmt.close();
                    } catch (SQLException e) {
                        e.printStackTrace();
                    }
                }
                if (con != null) {
                    try {
                        con.close();
                    } catch (SQLException e) {
                        e.printStackTrace();
                    }
                }
            }
        } catch (NullPointerException npe) {
            System.out.println("NullPointerException occured!");
            npe.printStackTrace();
        } catch (Exception e) {
            System.out.println("Generic Exception occured!");
        }
    }

    // tag::javadoc2[]
    /**
     * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse
     *      response)
     */
    // end::javadoc2[]
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
