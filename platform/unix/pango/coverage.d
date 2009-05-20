/*
 * coverage.d
 *
 * This file holds bindings to pango's pango-coverage.h. The original copyright
 * is displayed below, but does not pertain to this file.
 *
 * Author: Dave Wilkinson
 *
 */

module platform.unix.pango.coverage;

/* Pango
 * pango-coverage.h: Coverage sets for fonts
 *
 * Copyright (C) 2000 Red Hat Software
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Library General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.	 See the GNU
 * Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public
 * License along with this library; if not, write to the
 * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
 * Boston, MA 02111-1307, USA.
 */

import platform.unix.pango.types;

extern(C) struct _PangoCoverage;

extern(C):

alias _PangoCoverage PangoCoverage;

enum PangoCoverageLevel {
  PANGO_COVERAGE_NONE,
  PANGO_COVERAGE_FALLBACK,
  PANGO_COVERAGE_APPROXIMATE,
  PANGO_COVERAGE_EXACT
}

PangoCoverage *    pango_coverage_new     ();

PangoCoverage *    pango_coverage_ref     (PangoCoverage      *coverage);

void               pango_coverage_unref   (PangoCoverage      *coverage);

PangoCoverage *    pango_coverage_copy    (PangoCoverage      *coverage);

PangoCoverageLevel pango_coverage_get     (PangoCoverage      *coverage,
					   int                 index_);

void               pango_coverage_set     (PangoCoverage      *coverage,
					   int                 index_,
					   PangoCoverageLevel  level);

void               pango_coverage_max     (PangoCoverage      *coverage,
					   PangoCoverage      *other);

void           pango_coverage_to_bytes   (PangoCoverage  *coverage,
					  guchar        **bytes,
					  int            *n_bytes);

PangoCoverage *pango_coverage_from_bytes (guchar         *bytes,
					  int             n_bytes);
